function aws-ec2-ls () {
	aws ec2 describe-instances --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value, InstanceId, PublicDnsName]" \
			| jq 'flatten[]' \
			| sed 's/"//g' \
			| awk '
					BEGIN { K=0 }
					{ 
						if (NR % 3 == 1) {
							printf("%d)%s", K, $1)
							K++
						} else if (NR % 3 == 2) {
							printf("|%s", $1)
				  	} else {
							printf("|%s\n", $1)
				  	}
					}
				'
}
