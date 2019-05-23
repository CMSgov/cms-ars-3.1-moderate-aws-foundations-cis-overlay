# cms-ars-3.1-moderate-aws-foundations-cis-overlay
InSpec profile overlay to validate the secure configuration of vendor Amazon Web Services against [CIS'](https://www.cisecurity.org/cis-benchmarks/) Amazon Web Services Foundations Benchmark Version [1.1.0] tailored for [CMS ARS 3.1](https://www.cms.gov/Research-Statistics-Data-and-Systems/CMS-Information-Technology/InformationSecurity/Info-Security-Library-Items/ARS-31-Publication.html) for CMS systems categorized as Moderate.

## Getting Started  
It is intended and recommended that InSpec and this profile overlay be run from a __"runner"__ host (such as a DevOps orchestration server, an administrative management system, or a developer's workstation/laptop) against the target.

__For the best security of the runner, always install on the runner the _latest version_ of InSpec and supporting Ruby language components.__ 

Latest versions and installation options are available at the [InSpec](http://inspec.io/) site. Alternatively, you can use the AWS SSM suite to run InSpec on your AWS assets. More information can be found on the [AWS SSM](https://aws.amazon.com/blogs/mt/using-aws-systems-manager-to-run-compliance-scans-using-inspec-by-chef/) site.

This overlay also requires the AWS Command Line Interface (CLI) which is available at the [AWS CLI](https://aws.amazon.com/cli/) site.

The following attributes must be configured in an attributes file for the profile to run correctly. More information about InSpec attributes can be found in the [InSpec Profile Documentation](https://www.inspec.io/docs/reference/profiles/). These attributes are generated if the profile is used with the Terraform [hardening receipe](https://github.com/aaronlippold/cis-aws-foundations-hardening) with kitchen-terraform. Instructions on how to generate these attributes is also provided in the [Generate Attributes](#Generate-Attributes) section below.

````
# AWS key age (1.4)
aws_key_age: 60

# Make the password length (1.9)
pwd_length: 12

# Make the aws_cred_age an attribute (1.11)
aws_cred_age: 60

# Description: 'default aws region'
default_aws_region: 'us-east-1'

# Description: 'default aws region'
aws_region: 'us-east-1'

# Description: 'iam manager role name'
iam_manager_role_name: "iam_manager_role_name"

# Description: 'iam master role name'
iam_master_role_name: "iam_master_role_name"

# Description: 'iam manager user name'
iam_manager_user_name: "iam_manager_user_name"

# Description: 'iam master user name'
iam_master_user_name: "iam_master_user_name"

# Description: 'iam manager policy name'
iam_manager_policy_name: "iam_manager_policy"

# Description: 'iam master policy name'
iam_master_policy_name: "iam_master_policy"

# Description: 'list of instances that have specific roles'
aws_actions_performing_instance_ids: ["aws_access_instance_id"]

# Description: 'Config service list and settings in all relevant regions'

config_service:
    us-east-1: 
      s3_bucket_name: "s3_bucket_name_value"
      sns_topic_arn: "sns_topic_arn_value"
    us-east-2: 
      s3_bucket_name:  "s3_bucket_name_value"
      sns_topic_arn: "sns_topic_arn_value"
    us-west-1: 
      s3_bucket_name:  "s3_bucket_name_value"
      sns_topic_arn: "sns_topic_arn_value"
    us-west-2: 
      s3_bucket_name:  "s3_bucket_name_value"
      sns_topic_arn: "sns_topic_arn_value"


# Description: 'SNS topics list and details in all relevant regions'

sns_topics: 
    topic_arn1 : 
      owner : "owner_value"
      region : "region_value"
    topic_arn2 :
      owner : "owner_value"
      region : "region_value"`

# Description: 'SNS subscription list and details in all relevant regions'

sns_subscriptions: 
    subscription_arn1: 
      endpoint: "endpoint_value"
      owner: "owner_value"
      protocol: "protocol_value"
    subscription_arn2: 
      endpoint: "endpoint_value"
      owner: "owner_value"
      protocol: "protocol_value"`
````

## Generate Attributes

The generate_attributes.rb file within this repository may be used to generate part of the attributes required for the profile.
The script will inspect aws regions: us-east-1, us-east-2, us-west-1, us-west-2 to generate the following attributes to STDOUT.

```
- config_delivery_channels
- sns_topics
- sns_subscriptions
```
The generated attributes __must be reviewed carefully__. 
Only __valid__ channels and sns items should be placed in the attributes.yml file.

Usage:
```
  ruby generate_attributes.rb
```

## Running This Overlay
Prior to running this overlay, certain credentials and permissions need to be established for AWS CLI to work properly. 

1. The IAM account used to run this profile against the AWS environment needs to attached through a group or role with at least `AWS IAM "ReadOnlyAccess" Managed Policy` 

2. If running in an AWS Multi-Factor Authentication environment, derived credentials are needed to use the AWS CLI. Default `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` will not satisfy the MFA Policies in the CMS AWS environments. To do this, the AWS CLI environment needs to have the right system environment variables set with your AWS region and credentials and session key. InSpec supports the following standard AWS variables:

- `AWS_REGION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`

More information about these credentials and permissions can be found in the [AWS](https://docs.aws.amazon.com/cli/latest/reference/sts/get-session-token.html) documentation and [AWS Profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-multiple-profiles.html) documentation.

A useful bash script for automating this process is [here](https://gist.github.com/dinvlad/d1bc0a45419abc277eb86f2d1ce70625)

Furthermore, to generate credentials using an AWS Profile you will need to use the following AWS CLI commands.

  a. `aws sts get-session-token --serial-number arn:aws:iam::<$YOUR-MFA-SERIAL> --token-code <$YOUR-CURRENT-MFA-TOKEN> --profile=<$YOUR-AWS-PROFILE>` 

  b. Then export the `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_SESSION_TOKEN` that was generated by the above command.

When the __"runner"__ host uses this profile overlay for the first time, follow these steps: 

```
mkdir profiles
cd profiles
git clone https://github.com/mitre/cis-aws-foundations-baseline.git
git clone https://github.cms.gov/ISPG/cms-ars-3.1-moderate-aws-foundations-cis-overlay.git
cd cms-ars-3.1-moderate-aws-foundations-cis-overlay
bundle install
cd ..
inspec exec cms-ars-3.1-moderate-aws-foundations-cis-overlay --attrs=<path_to_your_attributes_file/name_of_your_attributes_file.yml> --target aws://<hostname>:<port> --user=<username> --password=<password> --reporter=cli json:<path_to_your_output_file/name_of_your_output_file.json>
```
For every successive run, follow these steps to always have the latest version of this overlay and dependent profiles:

```
cd profiles/<baseline-repo>
git pull
cd ../<overlay-repo>
git pull
bundle install
cd ..
inspec exec [overlay-name]-vendor-product-version-edition[-stig|cis-]-overlay --attrs=<path_to_your_attributes_file/name_of_your_attributes_file.yml> [-t <transport_protocol>://<hostname>:<port> --user=<username> --password=<password>] --reporter cli json:<filename>.json
```



## Usage

InSpec makes it easy to run your tests wherever you need. More options listed here: [InSpec cli](http://inspec.io/docs/reference/cli/)

```
# Clone Inspec Profile
$ git clone https://github.cms.gov/ispg-review/cms-ars3.1-cis-aws-foundations-baseline

# Install Gems
$ bundle install

# Set required ENV variables
$ export AWS_ACCESS_KEY_ID=key-id
$ export AWS_SECRET_ACCESS_KEY=access-key
$ export AWS_SESSION_TOKEN=session_token
$ export AWS_REGION=us-west-1

# Run the `generate_attributes.rb` 
$ ruby generate_attributes.rb
# The generated attributes __must be reviewed carefully__. 
# Only __valid__ channels and sns items should be placed in the attributes.yml file.

# To run profile locally and directly from Github
$ inspec exec /path/to/profile -t aws:// --attrs=attributes.yml

# To run profile locally and directly from Github with cli & json output 
$ inspec exec /path/to/profile -t aws:// --attrs=attributes.yml --reporter cli json:aws-results.json

# To run profile locally and directly from Github with cli & json output, in a specific region with a specific AWS profile
$ inspec exec /path/to/profile -t aws://us-east-1/<mycreds-profile> --attrs=attributes.yml --reporter cli json:aws-results.json
```

## Authors
* Eugene Aronne
* Danny Haynes

## Special Thanks
* Rony Xaiver
* Aaron Lippold

### Additional References

### License 

* This project is dual-licensed under the terms of the Apache license 2.0 (apache-2.0)
* This project is dual-licensed under the terms of the Creative Commons Attribution Share Alike 4.0 (cc-by-sa-4.0)
