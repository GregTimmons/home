#!/bin/bash
# /usr/local/bin/mysql-iam-connect-CLI.sh

# Usage instructions
usage() {
    cat << EOF
Usage:
    $(basename $0) AWS_PROFILE DB_HOST DB_NAME
    $(basename $0) AWS_PROFILE AWS_REGION DB_HOST DB_NAME

Connect to a MySQL database using IAM authentication.

Parameters:
    AWS_PROFILE     AWS SSO profile to use
    AWS_REGION      AWS region to use (optional, default: us-east-1)
    DB_HOST         RDS database hostname (can be an alias that resolves to the FQDN)
    DB_NAME         Database name to connect to

Examples:
    $(basename $0) my-profile my-db.cluster-xyz.us-east-1.rds.amazonaws.com my_database
    $(basename $0) my-profile us-west-2 my-db.cluster-xyz.us-west-2.rds.amazonaws.com my_database
EOF
    exit 1
}

# Function to check and install nslookup
check_nslookup() {
    if ! which nslookup &> /dev/null; then
        echo "nslookup not found, attempting to install..."
        
        if which apt-get &> /dev/null; then
            apt-get update && apt-get install -y dnsutils || { echo "Error: Failed to install dnsutils"; exit 1; }
        elif which yum &> /dev/null; then
            yum install -y bind-utils || { echo "Error: Failed to install bind-utils"; exit 1; }
        else
            echo "Error: No supported package manager found. Please install nslookup manually."
            exit 1
        fi
    fi
}

# Function to check and install AWS CLI
check_aws_cli() {
    if ! which aws &> /dev/null; then
        echo "AWS CLI not found, attempting to install latest version..."
        if which apt-get &> /dev/null; then
            apt-get update && apt-get install -y awscli || { echo "Error: Failed to install awscli"; exit 1; }
        elif which yum &> /dev/null; then
            yum install -y aws-cli || { echo "Error: Failed to install aws-cli"; exit 1; }
        elif which brew &> /dev/null; then
            brew install awscli || { echo "Error: Failed to install awscli"; exit 1; }
        else
            echo "Error: No supported package manager found. Please install AWS CLI manually."
            exit 1
        fi
    fi
}

# Function to check and install MySQL client
check_mysql() {
    if ! which mysql &> /dev/null; then
        echo "MySQL client not found, attempting to install..."
        
        if which apt-get &> /dev/null; then
            apt-get update && apt-get install -y mysql-client || { echo "Error: Failed to install mysql-client"; exit 1; }
        elif which yum &> /dev/null; then
            yum install -y mysql || { echo "Error: Failed to install mysql"; exit 1; }
        elif which brew &> /dev/null; then
            brew install mysql-client || { echo "Error: Failed to install mysql-client"; exit 1; }
        else
            echo "Error: No supported package manager found. Please install MySQL client manually."
            exit 1
        fi
    fi
}

# Function to check and install sed
check_sed() {
    if ! which sed &> /dev/null; then
        echo "sed not found, attempting to install..."
        
        if which apt-get &> /dev/null; then
            apt-get update && apt-get install -y sed || { echo "Error: Failed to install sed"; exit 1; }
        elif which yum &> /dev/null; then
            yum install -y sed || { echo "Error: Failed to install sed"; exit 1; }
        elif which brew &> /dev/null; then
            brew install gnu-sed || { echo "Error: Failed to install gnu-sed"; exit 1; }
        else
            echo "Error: No supported package manager found. Please install sed manually."
            exit 1
        fi
    fi
}

# Function to resolve hostname to FQDN
resolve_hostname() {
    local hostname=$1
    local final

    # Run nslookup and extract the last canonical name ending with .rds.amazonaws.com
    final=$(nslookup "$hostname" 2>/dev/null | awk '/canonical name/ {print $NF}' | grep '\.rds\.amazonaws\.com\.$' | tail -n1 | sed 's/\.$//')

    if [ -n "$final" ]; then
        echo "$final"
    else
        # If not found, fall back to the original hostname
        echo "$hostname"
    fi
}

# Parameter validation and argument parsing
if [ $# -eq 3 ]; then
    AWS_PROFILE=$1
    AWS_REGION="us-east-1"
    DB_HOST=$2
    DB_NAME=$3
elif [ $# -eq 4 ]; then
    AWS_PROFILE=$1
    AWS_REGION=$2
    DB_HOST=$3
    DB_NAME=$4
else
    echo "Error: Missing required parameters"
    usage
fi

# Validate AWS Profile
if ! aws configure list-profiles | grep -q "^${AWS_PROFILE}$"; then
    echo "Error: AWS Profile '${AWS_PROFILE}' not found"
    exit 1
fi

# Main script
main() {
    # Parameters are already set: AWS_PROFILE, AWS_REGION, DB_HOST, DB_NAME
    local DB_PORT=3306  # MySQL standard port

    # Check and install required dependencies
    check_aws_cli
    check_mysql
    check_sed
    check_nslookup

    # Resolve the hostname to FQDN if it's an alias
    echo "Resolving database hostname..."
    local RESOLVED_DB_HOST=$(resolve_hostname "$DB_HOST")
    if [ "$RESOLVED_DB_HOST" != "$DB_HOST" ]; then
        echo "Resolved $DB_HOST to $RESOLVED_DB_HOST"
    fi

    # Get user identity for database connection
    local USER_EMAIL=$(aws sts get-caller-identity --profile $AWS_PROFILE --region $AWS_REGION --query 'UserId' --output text | cut -d':' -f2)
    local DB_USERNAME=$(echo $USER_EMAIL | sed -e 's/@.*//g')

    echo "Setting up database connection..."
    echo "Host: $RESOLVED_DB_HOST"
    echo "Port: $DB_PORT"
    echo "Database: $DB_NAME"
    echo "Username: $DB_USERNAME"
    echo "Region: $AWS_REGION"
    echo

    # Generate RDS auth token before exec (since we won't be able to after)
    echo "Generating authentication token..."
    #local AUTH_TOKEN=$(
    echo aws rds generate-db-auth-token \
        --profile $AWS_PROFILE \
        --hostname $RESOLVED_DB_HOST \
        --port $DB_PORT \
        --region $AWS_REGION \
        --username $DB_USERNAME
    #)

    # Download SSL certificate if needed
    local SSL_CERT="$HOME/.mysql/root.crt"
    if [ ! -f "$SSL_CERT" ]; then
        echo "Downloading RDS SSL certificate..."
        mkdir -p "$HOME/.mysql"
        curl -s -o "$HOME/.mysql/global-bundle.pem" https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
        mv "$HOME/.mysql/global-bundle.pem" "$SSL_CERT"
    fi

    # Connect to MySQL using the generated token
    echo "Connecting to database..."
    mysql \
        --host=$RESOLVED_DB_HOST \
        --port=$DB_PORT \
        --user=$DB_USERNAME \
        --password="$AUTH_TOKEN" \
        --ssl-ca=$SSL_CERT \
        --enable-cleartext-plugin \
        $DB_NAME
}

# Run main script
main 
