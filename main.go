package main

import (
	"github.com/pulumi/pulumi-aws/sdk/v4/go/aws"
	"github.com/pulumi/pulumi-aws/sdk/v4/go/aws/ec2"
	"github.com/pulumi/pulumi-eks/sdk/go/eks"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi/config"
	"os"
)

type Networking struct {
	vpc    *ec2.Vpc
	subnet *ec2.Subnet
}

type K8s struct {
	cluster *eks.Cluster
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

func CreateSubnet(ctx *pulumi.Context, CidrBlock, Name string, Vpc *ec2.Vpc, Az, Env string, Public bool) (*Networking, error) {
	subnet, err := ec2.NewSubnet(ctx, Name, &ec2.SubnetArgs{
		VpcId:               Vpc.ID(),
		CidrBlock:           pulumi.String(CidrBlock),
		MapPublicIpOnLaunch: pulumi.Bool(Public),
		AvailabilityZone:    pulumi.String(Az),
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

func CreateEks(ctx *pulumi.Context, Name string, Vpc *ec2.Vpc, PbcSubnetId, PvtSubnetId *ec2.Subnet, Env string, NodePublic bool, AwsProfile string) (*K8s, error) {
	eks, err := eks.NewCluster(ctx, Name, &eks.ClusterArgs{
		VpcId: Vpc.ID(),
		PublicSubnetIds: pulumi.StringArray{
			PbcSubnetId.ID(),
		},
		PrivateSubnetIds: pulumi.StringArray{
			PvtSubnetId.ID(),
		},
		NodeAssociatePublicIpAddress: pulumi.Bool(NodePublic),
		InstanceType:                 pulumi.String("t2.medium"),
		ProviderCredentialOpts: &eks.KubeconfigOptionsArgs{
			ProfileName: pulumi.String(AwsProfile),
		},
		Tags: pulumi.StringMap{
			"Name": pulumi.String(Name),
			"Env":  pulumi.String(Env),
		},
	})

	if err != nil {
		return nil, err
	}

	return &K8s{
		cluster: eks,
	}, nil
}

func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {
		// Getting AWS Profile
		awsProfile, err := config.Try(ctx, "aws:profile")
		if err == nil {
			awsProfile = os.Getenv("AWS_PROFILE")
		}

		// Fetch AZs
		azState := "available"

		azs, err := aws.GetAvailabilityZones(ctx, &aws.GetAvailabilityZonesArgs{
			State: &azState,
		}, nil)

		if err != nil {
			return err
		}

		// Create k8s vpc
		eksVpc, err := CreateVpc(ctx, "10.200.0.0/20", "vpc-eks", "dev")

		if err != nil {
			return err
		}
		ctx.Export("VpcId", eksVpc.vpc.ID())

		// Create k8s private subnet
		eksPvtSubnet, err := CreateSubnet(ctx, "10.200.8.0/24", "eks-sbnt-private", eksVpc.vpc, azs.Names[0], "dev", false)
		if err != nil {
			return err
		}
		ctx.Export("PvtSubnetId", eksPvtSubnet.subnet.ID())

		// Create k8s public subnet
		eksPbcSubnet, err := CreateSubnet(ctx, "10.200.9.0/24", "eks-sbnt-public", eksVpc.vpc, azs.Names[1], "dev", true)
		if err != nil {
			return err
		}
		ctx.Export("PbcSubnetId", eksPbcSubnet.subnet.ID())

		// Create k8s cluster
		eksCluster, err := CreateEks(ctx, "eks-testing", eksVpc.vpc, eksPbcSubnet.subnet, eksPvtSubnet.subnet, "dev", false, awsProfile)
		if err != nil {
			return err
		}
		ctx.Export("eks-kubeconfig", eksCluster.cluster.Kubeconfig)

		return nil
	})
}
