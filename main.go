package main

import (
	"github.com/pulumi/pulumi-aws/sdk/v4/go/aws/ec2"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

type Networking struct {
	vpc    *ec2.Vpc
	subnet *ec2.Subnet
}

func CreateVpc(ctx *pulumi.Context, CidrBlock, Name, Env string) (*Networking, error) {
	vpc, err := ec2.NewVpc(ctx, Name, &ec2.VpcArgs{
		CidrBlock: pulumi.String(CidrBlock),
		Tags: pulumi.StringMap{
			"Name": pulumi.String(Name),
			"Env":  pulumi.String(Env),
		},
	})

	if err != nil {
		return nil, err
	}

	return &Networking{
		vpc: vpc,
	}, nil
}

func CreateSubnet(ctx *pulumi.Context, CidrBlock, Name string, VpcId pulumi.StringOutput, Env string, Public bool) (*Networking, error) {
	subnet, err := ec2.NewSubnet(ctx, Name, &ec2.SubnetArgs{
		VpcId:               VpcId,
		CidrBlock:           pulumi.String(CidrBlock),
		MapPublicIpOnLaunch: pulumi.Bool(Public),
		Tags: pulumi.StringMap{
			"Name": pulumi.String(Name),
			"Env":  pulumi.String(Env),
		},
	})

	if err != nil {
		return nil, err
	}

	return &Networking{
		subnet: subnet,
	}, nil
}

func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {
		// Create k8s vpc
		eksVpc, err := CreateVpc(ctx, "10.200.0.0/20", "vpc-eks", "dev")

		if err != nil {
			return err
		}
		ctx.Export("VpcId", eksVpc.vpc.ID())

		// Create k8s private subnet
		eksPvtSubnet, err := CreateSubnet(ctx, "10.200.8.0/24", "eks-sbnt-private", pulumi.StringOutput(eksVpc.vpc.ID()), "dev", false)
		if err != nil {
			return err
		}
		ctx.Export("PvtSubnetId", eksPvtSubnet.subnet.ID())

		// Create k8s public subnet
		eksPbcSubnet, err := CreateSubnet(ctx, "10.200.9.0/24", "eks-sbnt-public", pulumi.StringOutput(eksVpc.vpc.ID()), "dev", true)
		if err != nil {
			return err
		}
		ctx.Export("PbcSubnetId", eksPbcSubnet.subnet.ID())

		return nil
	})
}
