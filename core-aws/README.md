## vpc

subnet sizing: https://docs.aws.amazon.com/quickstart/latest/vpc/architecture.html#subnet-sizing

```
# Generic child account configuration

## Notes

10.0.0.0/16
Private (ECS, Lambda, EKS): 10.0.0.0/17 -> 32766
datastore: 10.0.128.0/18 -> 16382
Public: 10.0.192.0/19 -> 8190
Spare: 10.0.224.0/19
```

- tervezzuk 2 AZ-re
- kell 2 NAT gateway vagy akar eleg csak 1? 
- subnet, per AZ:
  - 1 public
  - 1 private vagy 1 private compute es 1 private datastore (probalok generic neveket talalni ide)
  - vmennyi reserved


https://github.com/terraform-aws-modules/terraform-aws-vpc#private-versus-intra-subnets
https://github.com/terraform-aws-modules/terraform-aws-vpc#examples