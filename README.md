# bare-metal-nested-virtualization

O propósito desse repositório é mostrar formas de virtualização utilizando KVM em um servidor bare metal na AWS

Esse tipo de instâncias EC2 oferecem o melhor dos dois mundos, permitindo que o sistema operacional seja executado diretamente no hardware subjacente, ao mesmo tempo que fornece acesso a todos os benefícios da nuvem.

[Amazon EC2 Bare Metal Instances](https://aws.amazon.com/blogs/aws/new-amazon-ec2-bare-metal-instances-with-direct-access-to-hardware/)

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

Neste repositório existem alguns scripts que nos ajudarão a realizar todos as etapas de configuração.

```bash
ssh -i bare-metal-demo.pem ubuntu@XXX.XXX.XXX.XXX
```

Realize SSH no servidor e siga os passos a seguir:


```bash
sudo su - 
```

```bash
cd /opt/ && apt-get update && apt-get install git -y
```

```
git clone https://github.com/BRCentralSA/bare-metal-nested-virtualization.git
```

Realize a instalacão do KVM e dos componentes necessários

```
cd bare-metal-nested-virtualization && ./install-kvm-ubuntu.sh
```

# Criando nosso primeiro servidor Ubuntu

Nesta demonstração iremos criar um servidor Ubuntu 18.04 com 1GB de RAM e 2 vCpu

```
./create-ubuntu-vm.sh
```

Aguarde a finalização da criação, pode levar algum tempo, após finalizar será necessário realizar o login novamente no servidor

# Definindo um IP estático utilizando a rede Default Nat-based networking

Iremos utilizar a rede **default** criada no processo de instalação do KVM

Utilizando o **virsh**

Você pode criar, excluir, executar, parar e gerenciar suas máquinas virtuais a partir da linha de comando, usando uma ferramenta chamada virsh. Virsh é particularmente útil para administradores Linux avançados, interessados ​​em scripts ou automatizar alguns aspectos do gerenciamento de suas máquinas virtuais

```bash
virsh net-list
```


```bash
virsh net-info default
```

A rede baseada em NAT é comumente fornecida e habilitada como padrão pela maioria das principais distribuições de Linux que suportam virtualização KVM.

Esta configuração de rede usa uma ponte Linux em combinação com Network Address Translation (NAT) para permitir que um sistema operacional convidado obtenha conectividade de saída, independentemente do tipo de rede (com fio, sem fio, dial-up e assim por diante) usado no host KVM sem exigindo qualquer configuração de administrador específica.
