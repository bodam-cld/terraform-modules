## vpc

subnet sizing: https://docs.aws.amazon.com/quickstart/latest/vpc/architecture.html#subnet-sizing

```
10.0.0.0/16
Private (ECS, Lambda, EKS): 10.0.0.0/17 -> 32766
Datastore: 10.0.128.0/18 -> 16382
Public: 10.0.192.0/19 -> 8190
Spare: 10.0.224.0/19
```
