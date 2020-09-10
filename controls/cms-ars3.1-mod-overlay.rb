# encoding: utf-8

include_controls "aws-foundations-cis-baseline" do

  control "aws-foundations-cis-1.4" do
    title "Ensure access keys are rotated every 60 days or less"
    desc  "check", "Perform the following to determine if access keys are rotated as prescribed:
      1. Login to the AWS Management Console
      2. Click `Services`
      3. Click `IAM`
      4. Click on `Credential Report`
      5. This will download an `.xls` file which contains Access Key usage for all IAM users within an AWS Account - open this file
      6. Focus on the following columns (where x = 1 or 2)
       - `access_key_X_active`
       - `access_key_X_last_rotated`
      7. Ensure all active keys have been rotated within `60` days
  
      Via CLI
      ```
      aws iam generate-credential-report
      aws iam get-credential-report --query 'Content' --output text | base64 -d
      ```"
    desc  "fix", "Perform the following to rotate access keys:
      1. Login to the AWS Management Console:
      2. Click `Services`
      3. Click `IAM`
      4. Click on `Users`
      5. Click on `Security Credentials`
      6. As an Administrator
       - Click on `Make Inactive` for keys that have not been rotated in `60` Days
      7. As an IAM User
       - Click on `Make` `Inactive` or `Delete` for keys which have not been rotated or used in `60` Days
      8. Click on `` Create Access ` Key`
      9. Update programmatic call with new Access Key credentials
  
      Via CLI
      ```
      aws iam update-access-key
      aws iam create-access-key
      aws iam delete-access-key
      ```"
  end

  control "aws-foundations-cis-1.9" do
    title "Ensure IAM password policy requires minimum length of 12 or greater"
    desc  "Password policies are, in part, used to enforce password complexity requirements. IAM password policies can be used to ensure password are at least a given length. It is recommended that the password policy require a minimum password length 12."
    desc  "check", "Perform the following to ensure the password policy is configured as prescribed:
  
      Via AWS Console
      1. Login to AWS Console (with appropriate permissions to View Identity Access Management Account Settings)
      2. Go to IAM Service on the AWS Console
      3. Click on Account Settings on the Left Pane
      4. Ensure \"Minimum password length\" is set to 12 or greater.
  
      Via CLI
      ```
      aws iam get-account-password-policy
      ```
      Ensure the output of the above command includes \"MinimumPasswordLength\": 12 (or higher)"
    desc  "fix", "Perform the following to set the password policy as prescribed:
  
      Via AWS Console
      1. Login to AWS Console (with appropriate permissions to View Identity Access Management Account Settings)
      2. Go to IAM Service on the AWS Console
      3. Click on Account Settings on the Left Pane
      4. Set \"Minimum password length\" to `12` or greater.
      5. Click \"Apply password policy\"
  
       Via CLI
      ```
       aws iam update-account-password-policy --minimum-password-length 12
      ```
      Note: All commands starting with \"aws iam update-account-password-policy\" can be combined into a single command."
  end

  control "aws-foundations-cis-1.11" do
    title "Ensure IAM password policy expires passwords within 60 days or less"
    desc  "IAM password policies can require passwords to be rotated or expired after a given number of days. It is recommended that the password policy expire passwords after 60 days or less."
    desc  "check", "Perform the following to ensure the password policy is configured as prescribed:
  
      Via AWS Console:
  
      1. Login to AWS Console (with appropriate permissions to View Identity Access Management Account Settings)
      2. Go to IAM Service on the AWS Console
      3. Click on Account Settings on the Left Pane
      4. Ensure \"Enable password expiration\" is checked
      5. Ensure \"Password expiration period (in days):\" is set to 60 or less
  
      Via CLI
      ```
      aws iam get-account-password-policy
      ```
      Ensure the output of the above command includes \"MaxPasswordAge\": 60 or less"
    desc  "fix", "Perform the following to set the password policy as prescribed:
  
      Via AWS Console:
  
      1. Login to AWS Console (with appropriate permissions to View Identity Access Management Account Settings)
      2. Go to IAM Service on the AWS Console
      3. Click on Account Settings on the Left Pane
      4. Check \"Enable password expiration\"
      5. Set \"Password expiration period (in days):\" to 60 or less
  
       Via CLI
      ```
       aws iam update-account-password-policy --max-password-age 60
      ```
      Note: All commands starting with \"aws iam update-account-password-policy\" can be combined into a single command."
  end

end