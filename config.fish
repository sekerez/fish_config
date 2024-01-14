
#
# PATH
#
fish_add_path "/opt/homebrew/bin/" # brew
fish_add_path "/usr/local/bin/"    # aws

#
# THEME
#

set_color green "#39DD14"

starship init fish | source
set -U fish_prompt_pwd_dir_length 0
if status is-interactive
    # Commands to run in interactive sessions can go here
end

#
# PERSONAL
#

# keyboard shenanigans
set COLEMAK false

# app configuration
set HOMEBREW_EDITOR "nvim"

# abbreviations
abbr --add lg lazygit
abbr --add toc cd ~/.config

#
# ALZA
#

# navigation
abbr --add tol  cd ~/alza/landing-page
abbr --add tos  cd ~/alza/alza-server
abbr --add tom  cd ~/alza/alza-mobile

# aws shenanigans

function mfa
    # Replace this with whatever you labeled your key with in ykman
    set ykprofile aws
    set key (ykman oath accounts code $ykprofile -s)
    echo $key | pbcopy
    set key ""
end

function reset-aws
    set -e AWS_ACCESS_KEY_ID
    set -e AWS_SECRET_ACCESS_KEY
    set -e AWS_DEFAULT_REGION
    set -e AWS_SESSION_TOKEN

    set ykprofile aws
    set key (ykman oath accounts code $ykprofile -s)
    echo $key

    set AWS_CREDS (aws sts get-session-token --serial-number arn:aws:iam::502131523815:mfa/alza_virtual_yubi --token-code $key)

    set AWS_ACCESS_KEY_ID (echo $AWS_CREDS | jq -r '.[].AccessKeyId')
    set AWS_SECRET_ACCESS_KEY (echo $AWS_CREDS | jq -r '.[].SecretAccessKey')
    set AWS_DEFAULT_REGION 'us-east-2'
    set AWS_SESSION_TOKEN (echo $AWS_CREDS | jq -r '.[].SessionToken')
    set AWS_TOKEN_EXPIRATION (echo $AWS_CREDS | jq -r '.[].Expiration')

    set -x AWS_ACCESS_KEY_ID $AWS_ACCESS_KEY_ID
    set -x AWS_SECRET_ACCESS_KEY $AWS_SECRET_ACCESS_KEY
    set -x AWS_DEFAULT_REGION $AWS_DEFAULT_REGION
    set -x AWS_SESSION_TOKEN $AWS_SESSION_TOKEN

    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile mfa
    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile mfa 
    aws configure set aws_session_token $AWS_SESSION_TOKEN --profile mfa 
    aws configure set default.region $AWS_DEFAULT_REGION --profile mfa

    echo "Tokens generated and saved to this terminal session. Tokens will expire on $AWS_TOKEN_EXPIRATION"
end
