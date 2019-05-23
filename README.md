# cms-ars-3.1-moderate-aws-foundations-cis-overlay
InSpec profile overlay to validate the secure configuration of vendor Amazon Web Services against [CIS'](https://www.cisecurity.org/cis-benchmarks/) Amazon Web Services Foundations Benchmark Version 1.1.0 tailored for [CMS ARS 3.1](https://www.cms.gov/Research-Statistics-Data-and-Systems/CMS-Information-Technology/InformationSecurity/Info-Security-Library-Items/ARS-31-Publication.html) for CMS systems categorized as Moderate.

## Getting Started  
It is intended and recommended that InSpec and this profile overlay be run from a __"runner"__ host (such as a DevOps orchestration server, an administrative management system, or a developer's workstation/laptop) against the target.

__For the best security of the runner, always install on the runner the _latest version_ of InSpec and supporting Ruby language components.__ 

Latest versions and installation options are available at the [InSpec](http://inspec.io/) site. Alternatively, you can use the AWS SSM suite to run InSpec on your AWS assets. More information can be found on the [AWS SSM](https://aws.amazon.com/blogs/mt/using-aws-systems-manager-to-run-compliance-scans-using-inspec-by-chef/) site.

This overlay also requires the AWS Command Line Interface (CLI) which is available at the [AWS CLI](https://aws.amazon.com/cli/) site.

The following attributes must be configured in an attributes file for the profile to run correctly. More information about InSpec attributes can be found in the [InSpec Profile Documentation](https://www.inspec.io/docs/reference/profiles/). These attributes are generated if the profile is used with the Terraform [hardening receipe](https://github.com/aaronlippold/cis-aws-foundations-hardening) with kitchen-terraform. Instructions on how to generate these attributes is also provided in the [Generate Attributes](#Generate-Attributes) section below.

````
# Description: AWS key age (e.g., 60)
aws_key_age: 

# Description: Make the password length (e.g., 12)
pwd_length: 

# Description: Make the aws_cred_age an attribute (e.g., 60)
aws_cred_age: 

# Description: Default AWS region (e.g., 'us-east-1')
default_aws_region: ''

# Description: AWS region (e.g., 'us-east-1')
aws_region: ''

# Description: IAM manager role name 
iam_manager_role_name: ''

# Description: IAM master role name
iam_master_role_name: ''

# Description: IAM manager user name
iam_manager_user_name: ''

# Description: IAM master user name
iam_master_user_name: ''

# Description: IAM manager policy name
iam_manager_policy_name: ''

# Description: IAM master policy name
iam_master_policy_name: ''

# Description: List of instances that have specific roles (e.g., ['aws_access_instance_id']) 
aws_actions_performing_instance_ids: []

# Description: Config service list and settings in all relevant regions

config_service:
    us-east-1: 
      s3_bucket_name: ''
      sns_topic_arn: ''
    us-east-2: 
      s3_bucket_name:  ''
      sns_topic_arn: ''
    us-west-1: 
      s3_bucket_name:  ''
      sns_topic_arn: ''
    us-west-2: 
      s3_bucket_name:  ''
      sns_topic_arn: ''


# Description: SNS topics list and details in all relevant regions

sns_topics: 
    topic_arn1 : 
      owner : ''
      region : ''
    topic_arn2 :
      owner : ''
      region : ''

# Description: SNS subscription list and details in all relevant regions

sns_subscriptions: 
    subscription_arn1: 
      endpoint: ''
      owner: ''
      protocol: ''
    subscription_arn2: 
      endpoint: ''
      owner: ''
      protocol: ''
````

## Generate Attributes

The generate_attributes.rb file within this repository may be used to generate part of the attributes required for the profile.
The script will inspect AWS regions (us-east-1, us-east-2, us-west-1, us-west-2) to generate the following attributes to STDOUT.

```
- config_delivery_channels
- sns_topics
- sns_subscriptions
```
The generated attributes __must be reviewed carefully__. Only __valid__ channels and sns items should be placed in the attributes.yml file. Use the following command to run the script.

```
  ruby generate_attributes.rb
```

## Running This Overlay
Prior to running this overlay, certain credentials and permissions need to be established for AWS CLI to work properly. 

1. The IAM account used to run this profile against the AWS environment needs to attached through a group or role with at least `AWS IAM "ReadOnlyAccess" Managed Policy` 

2. If running in an AWS Multi-Factor Authentication (MFA) environment, derived credentials are needed to use the AWS CLI. Default `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` will not satisfy the MFA Policies in the CMS AWS environments. To do this, the AWS CLI environment needs to have the right system environment variables set with your AWS region and credentials and session key. InSpec supports the following standard AWS variables:

- `AWS_REGION`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`

The environment variables can be set using the following commands.

````
# Set required ENV variables
$ export AWS_ACCESS_KEY_ID=<key-id>
$ export AWS_SECRET_ACCESS_KEY=<access-key>
$ export AWS_SESSION_TOKEN=<session_token>
$ export AWS_REGION='<region>'
````

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
inspec exec cms-ars-3.1-moderate-aws-foundations-cis-overlay --attrs=<path_to_your_attributes_file/name_of_your_attributes_file.yml> --target aws://<hostname>:<port> --user=<username> --password=<password> --reporter=cli json:<path_to_your_output_file/name_of_your_output_file.json>
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
