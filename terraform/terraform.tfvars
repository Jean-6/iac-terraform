# Identifiant du compte AWS
account_id = "111122223333"

# VPC cible
vpc_id = "vpc-xxxx"

# Subnets publics
public_subnet_ids = ["subnet-aaa", "subnet-bbb"]

# Private subnets
private_subnet_ids = ["subnet-ccc", "subnet-ddd"]

# Nom de l'application (utilisé pour nommer les ressources)
app_name = "vegnbio-api"

# Région AWS
aws_region = "eu-west-3"

# Tag de l'image Docker dans ECR
image_tag = "latest"


#private_subnet_ids = [
#  aws_subnet.private_1.id,
#  aws_subnet.private_2.id
#]