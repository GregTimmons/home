function aws-ec2-ls () {
	aws ec2 describe-instances --query "Reservations[*].Instances[*].[InstanceId, Tags[?Key=='Name'].Value, PublicDnsName]" \
			| jq 'flatten[]' \
			| sed 's/"//g' \
			| awk '
					BEGIN { K=0 }
					{ 
						if (NR % 3 == 1) {
							printf("%2d) %-15s", K, $0)
							K++
						} else if (NR % 3 == 2) {
							printf(" %-35s", $0)
				  	} else {
							printf("  %s\n", $1)
				  	}
					}
				'
}
