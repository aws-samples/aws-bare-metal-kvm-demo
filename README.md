# bare-metal-nested-virtualization

O propósito desse repositório é mostrar formas de virtualização utilizando KVM em um servidor bare metal hospedado na AWS

# Pré Requisitos

- Amazon VPC configurada com no minínimo uma subnet pública

# Criando nossa Amazon EC2

Para essa demonstração utilizaremos a EC2 do tipo **i3.metal**:

> [i3.metal](https://aws.amazon.com/pt/ec2/instance-types/i3/)

Logue no console da AWS e selecione EC2 > instances > Launch Instance

<p align="center"> 
<img src="images/ec2-01.png">
</p>

>Obs: Utilizaremos o Ubuntu 18.04 como sistema operacional

Selecione a instância do tipo i3.large > Configure Instance Details

<p align="center"> 
<img src="images/ec2-02.png">
</p>

Selecione a VPC onde você quer fazer o lançamento da sua instância e também a subnet

>Obs: Será necessário realizar SSH na instância portanto, realize o lançamento em uma subnet pública ou possua mecânismos para acessar sua instância (VPN/Bastion)

Selecione a quantidade de GB para o volume Root (Utilizaremos essa máquina virtual para realizar virtualização portanto defina uma quantidade adequada)

<p align="center"> 
<img src="images/ec2-03.png">
</p>

Defina a Tag Name para a sua EC2

<p align="center"> 
<img src="images/ec2-04.png">
</p>

> Obs: Utilizarei o nome kvm-virtualization-lab

Clique em **Configure Security Group**

Crie um Security Group específico para a sua EC2 ou seleciona um já existente.

>Obs: Lembre-se de verificar as portas necessárias no Security Group para realizar o acesso remoto as nossas máquinas virtualizadas

Clique em **Review and Launch**

Valide as informações e clique em **Launch**

Crie uma chave privada .pem caso você não possua ou utilize uma já existente

<p align="center"> 
<img src="images/ec2-05.png">
</p>

Clique em **Launch Instance**

Aguarde alguns minutos para que sua EC2 esteja pronta para ser acessada

<p align="center"> 
<img src="images/ec2-06.png">
</p>

# Instalando o KVM