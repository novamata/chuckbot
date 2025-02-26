# ChuckBot

Ever wanted to have a bot that posts a random Chuck Norris quote to a Discord channel every day?

This is the perfect solution for you!

Using AWS this can be run with little to no upkeep, utilizing services such as Lambda and CloudWatch.

## How to use

1. Clone the repository
2. Create a terraform.tfvars file and fill it with your Discord values, using the example below
3. Run `terraform init` in the terraform directory
4. Run `terraform apply -var-file="terraform.tfvars"`
5. Run `terraform destroy` when you're done using it 


Directory structure:
```
/
├── lambda_function.py       
├── lambda_layer
│       └── discord_layer.zip 
└── terraform
    └── main.tf
    └── variables.tf
    └── data.tf
```

terraform.tfvars file exmaple
```
discord_token = ""
discord_channel_id = ""
```

## Resources

How to create a Discord Bot
- https://discordpy.readthedocs.io/en/stable/discord.html

Chuck Norris API
- https://api.chucknorris.io/



