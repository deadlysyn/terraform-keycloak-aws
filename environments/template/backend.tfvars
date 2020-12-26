region         = "%%REGION%%"
bucket         = "%%NAMESPACE%%-%%ENVIRONMENT%%-%%NAME%%-state"
key            = "terraform.tfstate"
dynamodb_table = "%%NAMESPACE%%-%%ENVIRONMENT%%-%%NAME%%-lock"
encrypt        = true
