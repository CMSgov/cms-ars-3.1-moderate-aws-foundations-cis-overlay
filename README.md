# cms-ars-3.1-moderate-aws-foundations-cis-overlay
**CMS’ ISPG (Information Security and Privacy Group) decided to discontinue funding the customization of MITRE’s Security Automation Framework (SAF) for CMS after September 2023. This repo is now in archive mode, but still accessible. For more information about SAF with current links, see https://security.cms.gov/learn/security-automation-framework-saf**

InSpec profile overlay to validate the secure configuration of Amazon Web Services against [CIS'](https://www.cisecurity.org/cis-benchmarks/) Amazon Web Services Foundations Benchmark Version 1.2.0 tailored for [CMS ARS 3.1](https://www.cms.gov/Research-Statistics-Data-and-Systems/CMS-Information-Technology/InformationSecurity/Info-Security-Library-Items/ARS-31-Publication.html) for CMS systems categorized as Moderate.

## Getting Started  
It is intended and recommended that InSpec and this profile overlay be run from a __"runner"__ host (such as a DevOps orchestration server, an administrative management system, or a developer's workstation/laptop) against the target remotely over __ssh__.

__For the best security of the runner, always install on the runner the _latest version_ of InSpec and supporting Ruby language components.__ 

Latest versions and installation options are available at the [InSpec](http://inspec.io/) site. Alternatively, you can use the AWS SSM suite to run InSpec on your AWS assets. More information can be found on the [AWS SSM](https://aws.amazon.com/blogs/mt/using-aws-systems-manager-to-run-compliance-scans-using-inspec-by-chef/) site.

This overlay also requires the AWS Command Line Interface (CLI) which is available at the [AWS CLI](https://aws.amazon.com/cli/) site.

## Tailoring to Your Environment
The following inputs must be configured in an inputs ".yml" file for the profile to run correctly for your specific environment. More information about InSpec inputs can be found in the [InSpec Profile Documentation](https://www.inspec.io/docs/reference/profiles/). If the profile is used with the Terraform [hardening recipe](https://github.com/mitre/cis-aws-foundations-hardening) with kitchen-terraform, inputs are autogenerated by kitchen. Instructions on how to generate these inputs is also provided in the [Generate Inputs](#Generate-Inputs) section below.

```
# Used by InSpec check 2.5
# Description: Default AWS region
default_aws_region: 'us-east-1'

# Used by InSpec check 2.5
# Description: Config service list and settings in all relevant regions
config_delivery_channels:
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

```

## Generate Inputs

The generate_inputs.rb file within this repository may be used to generate part of the inputs required for the profile.
The script will inspect AWS regions (us-east-1, us-east-2, us-west-1, us-west-2) to generate the following inputs to STDOUT.

```
- config_delivery_channels
```
The generated inputs __must be reviewed carefully__. Only __valid__ channels and sns items should be placed in the inputs.yml file. Use the following command to run the script.

```
  ruby generate_inputs.rb
```

## Additional optional inputs the user may add to their inputs file:

```
# description: 'list of buckets exempted from inspection',
exception_bucket_list: ["exception_bucket_name"]

# description: 'list of security groups exempted from inspection',
exception_security_group_list: ["exception_security_group_name"]
```

## Configuring Your Environment
Prior to running this overlay, certain credentials and permissions need to be established for the AWS CLI to work properly. 

1. The IAM account used to run this profile against the AWS environment needs to be attached through a group or role with at least `AWS IAM "ReadOnlyAccess" Managed Policy`. 

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

## Running This Overlay Directly from Github

```
# How to run
inspec exec https://github.com/CMSgov/cms-ars-3.1-moderate-aws-foundations-cis-overlay/archive/master.tar.gz --input-file=<path_to_your_inputs_file/name_of_your_inputs_file.yml> --target aws:// --reporter=cli json:<path_to_your_output_file/name_of_your_output_file.json>
```

### Different Run Options

  [Full exec options](https://docs.chef.io/inspec/cli/#options-3)

## Running This Overlay from a local Archive copy 

If your runner is not always expected to have direct access to GitHub, use the following steps to create an archive bundle of this overlay and all of its dependent tests:

(Git is required to clone the InSpec profile using the instructions below. Git can be downloaded from the [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) site.)

When the __"runner"__ host uses this profile overlay for the first time, follow these steps: 

```
mkdir profiles
cd profiles
git clone https://github.com/CMSgov/cms-ars-3.1-moderate-aws-foundations-cis-overlay.git
inspec archive cms-ars-3.1-moderate-aws-foundations-cis-overlay
inspec exec <name of generated archive> --input-file <path_to_your_input_file/name_of_your_input_file.yml> --target aws:// --reporter=cli json:<path_to_your_output_file/name_of_your_output_file.json>
```

For every successive run, follow these steps to always have the latest version of this overlay and dependent profiles:

```
cd cms-ars-3.1-moderate-aws-foundations-cis-overlay
git pull
cd ..
inspec archive cms-ars-3.1-moderate-aws-foundations-cis-overlay --overwrite
inspec exec <name of generated archive> --input-file <path_to_your_input_file/name_of_your_input_file.yml> --target aws:// --reporter=cli json:<path_to_your_output_file/name_of_your_output_file.json>
```

## Using Heimdall for Viewing the JSON Results

The JSON results output file can be loaded into __[heimdall-lite](https://heimdall-lite.mitre.org/)__ for a user-interactive, graphical view of the InSpec results. 

The JSON InSpec results file may also be loaded into a __[full heimdall server](https://github.com/mitre/heimdall)__, allowing for additional functionality such as to store and compare multiple profile runs.

## Authors
* Eugene Aronne - [ejaronne](https://github.com/ejaronne)
* Danny Haynes - [djhaynes](https://github.com/djhaynes)
* Shivani Karikar - [karikarshivani](https://github.com/karikarshivani)

## Special Thanks
* Rony Xavier - [rx294](https://github.com/rx294)
* Aaron Lippold - [aaronlippold](https://github.com/aaronlippold)

## Contributing and Getting Help
To report a bug or feature request, please open an [issue](https://github.com/CMSgov/cms-ars-3.1-moderate-aws-foundations-cis-overlay/issues/new).

### NOTICE

© 2018-2020 The MITRE Corporation.

Approved for Public Release; Distribution Unlimited. Case Number 18-3678.

### NOTICE 

MITRE hereby grants express written permission to use, reproduce, distribute, modify, and otherwise leverage this software to the extent permitted by the licensed terms provided in the LICENSE.md file included with this project.

### NOTICE  

This software was produced for the U. S. Government under Contract Number HHSM-500-2012-00008I, and is subject to Federal Acquisition Regulation Clause 52.227-14, Rights in Data-General.  

No other use other than that granted to the U. S. Government, or to those acting on behalf of the U. S. Government under that Clause is authorized without the express written permission of The MITRE Corporation.

For further information, please contact The MITRE Corporation, Contracts Management Office, 7515 Colshire Drive, McLean, VA  22102-7539, (703) 983-6000.

### NOTICE 

CIS Benchmarks are published by the Center for Internet Security (CIS), see: https://www.cisecurity.org/.
