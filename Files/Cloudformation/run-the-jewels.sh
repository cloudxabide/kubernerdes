INPUT=amazon-vpc-3-public-private-tgw-subnets-params.yaml
OUTPUT=myparams.out
grep -v ^# $INPUT | while read ParameterKey ParameterValue; do echo -e "  {\n    \"ParameterKey\": \"${ParameterKey}\",\n    \"ParameterValue\": \"${ParameterValue}\"\n  },"; done > ${OUTPUT}
#- once you have the params.json created, add open/close square-brackets at the beginning and end
case `sed --version | head -1` in
  *GNU*)
    # Add the '[' to the beginning of the file
    sed -i -e '1i[' ${OUTPUT}
    # Remove the trailing ',' from the last entry
    sed  -i '$ s/},/}/' ${OUTPUT}
  ;;
  *)
sed -i'' '1i\
[\
' ${OUTPUT}
  ;;
esac
# Add the trailing square-bracket
echo "]" >> ${OUTPUT}
aws cloudformation create-stack --region us-east-1 --stack-name "VpcNetworking" --template-body file://amazon-vpc-3-public-private-tgw-subnets.yaml --parameters file://myparams.out
