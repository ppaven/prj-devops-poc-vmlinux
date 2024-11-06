[comment]: <> (
  Le code entre les balise '<!--' et '-->' est à conserver :
  Il permet de créer une table des matières lors de la génération du docx via le script gendoc.sh
)

<!--
```{=openxml}
<w:p>
  <w:r>
    <w:br w:type="page"/>
  </w:r>
</w:p>
<w:sdt>
  <w:sdtPr>
    <w:docPartObj>
      <w:docPartGallery w:val="Sommaire" /><w:docPartUnique />
    </w:docPartObj>
  </w:sdtPr>
  <w:sdtContent>
    <w:p>
      <w:pPr><w:pStyle w:val="En-ttedetabledesmatires" /></w:pPr>
      <w:r><w:t>Table des matières</w:t></w:r>
    </w:p>
    <w:p></w:p>
    <w:p>
      <w:r>
        <w:fldChar w:fldCharType="begin" w:dirty="true" />
        <w:instrText> TOC \o "1-3" \h \z \u</w:instrText><w:fldChar w:fldCharType="separate" />
        <w:fldChar w:fldCharType="end" />
      </w:r>
    </w:p>
  </w:sdtContent>
</w:sdt>
```
-->

# AzCloud Consulting : Projet Terraform et Azure DevOps

## Sommaire
- [AzCloud Consulting : Projet Terraform et Azure DevOps](#azcloud-consulting--projet-terraform-et-azure-devops)
  - [Sommaire](#sommaire)
- [1. Introduction](#1-introduction)
  - [1.1. Objet](#11-objet)
- [2. La démarche](#2-la-démarche)
- [3. WSL](#3-wsl)
- [4. Az CLI](#4-az-cli)
  - [4.1. Installation du Client Az](#41-installation-du-client-az)
- [5. Git](#5-git)
  - [5.1. Préparer l'environnement Git](#51-préparer-lenvironnement-git)
  - [5.2. Récupération du code Terraform : Clonage du projet](#52-récupération-du-code-terraform--clonage-du-projet)
- [6. Terraform](#6-terraform)
  - [6.1. Installation de Terraform](#61-installation-de-terraform)
  - [6.2. Structure du code Terraform](#62-structure-du-code-terraform)
  - [6.3. Etat partagé avec Azure Storage (backend)](#63-etat-partagé-avec-azure-storage-backend)
  - [6.4. Utilisation de Terraform](#64-utilisation-de-terraform)
    - [6.4.1. Connexion au tenant Azure](#641-connexion-au-tenant-azure)
    - [6.4.2. Initialisation du terraform](#642-initialisation-du-terraform)
    - [6.4.3. Exécution](#643-exécution)

# 1. Introduction

## 1.1. Objet

Ce document décrit l'utilisation de : 
* **Terraform** pour la création et modification des ressources dans Azure
* **Git** pour la gestion et le stockage du code Terraform
* **Az** (Command Line Interface Azure) pour la connexion au tenant Azure

# 2. La démarche
Dans notre démarche de build des fondations Azure de nos clients, nous utilisons autant que faire ce peut les technologies DevOps "Infra As Code", c'est à dire :  

- **Terraform**

Complété par les outils : 
* **Git** (dépot Azure DevOps, GitLab ou GitHub ) pour la gestion et le stockage du code Terraform
* **Az** (Command Line Interface Azure) pour la connexion au tenant Azure

Ainsi qu'un environnement **WSL** (Windows Subsytem for Linux) pour héberger ces outils.

# 3. WSL

**Terraform** et **Git** étant nativement conçus pour Linux, il apparait naturel d'installer un environnement **WSL** (Windows Subsystem for Linux) sur votre poste  de travail si celui-ci est de type Windows. 

Consulter : [WSL Install](https://learn.microsoft.com/fr-fr/windows/wsl/install-manual)

Choisir de préférence une distribution **Ubuntu**.

# 4. Az CLI
La "Command Line Interface" Az est un outil qui permet d'interagir avec Azure. 
Il permet d'établir une connexion à un tenant, de créer, modifier ou supprimer des ressources. 
Dans notre démarhe nous ne l'utilisons que pour établir un connexion au tenant Azure. La creation, modification, suppression des ressources étant géré via Terraform.

## 4.1. Installation du Client Az
```
$ curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

# 5. Git

l'outil Git est installé par défaut sur les systèmes Ubuntu.
Nous utilisons cet outil principallement pour stocker et partager le code Terraform sur notre dépot GitLab. 

## 5.1. Préparer l'environnement Git

- Generer une clef SSH sur l'environnement WSL
- Installer la clef SSH publique sur votre compte GitLab

## 5.2. Récupération du code Terraform : Clonage du projet

Lorsque votre environnemment est prêt vous pouvez procéder à l'installation du Playbook de la façon suivante : 
```
$ git clone --recursive git@ssh.dev.azure.com:v3/<Client>/<Projet>/terraform.git
```

# 6. Terraform

Le déploiement en utilisant du code terraform nous permet d’avoir un modèle générique, réutilisable et facilement redéployable. 

## 6.1. Installation de Terraform
```
$ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
$ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
$ sudo apt-get update && sudo apt-get install terraform
```

## 6.2. Structure du code Terraform

Le code est contenu dans une liste de fichiers : 
* `main.tf` : Contient la déclaration du provider (« azurerm »)
* `terraform.tf` : Contient la déclaration du backend (espace de stockage permettant de gérer les différences d’état)
* `vars.tf` : Déclaration des variables
* `terraform.<env>.tfvars` : Affectation des variables
* `vm.tf` : Code pour la création des ressources (VM)

## 6.3. Etat partagé avec Azure Storage (backend)
Pour pouvoir travailler à plusieurs sur un même état Terraform, il est nécessaire d'utiliser un stockage distant de l'état.
Le stockage de l'état dans Azure Storage permet de stocker cet état ainsi que lock. C'est le code contenu dans le fichier `terraform.tf`.

Exemple de configuration :
```
terraform {
  backend "azurerm" {
    storage_account_name = "xxxprdstotfback"
    container_name       = "tfstate"
    # key                  = "environment.nom-du-projet.tfstate"
  }
}
```
Un container Azure Storage nommé "tfstate" dans le compte "xxxprdstotfback" est disponible pour stocker dans des dossiers séparés les états distants des différents projets. Il faut ici remplacer "nom-du-projet" et "environment" par le nom réel du projet et l'environement courant.

Afin de ne pas diffuser l' Access Key de l'Azure Storage dans le dépot git des projets, il faut l'exporter sur la machine avant de lancer le Terraform :
```
$ export ARM_ACCESS_KEY=accesskey
```

## 6.4. Utilisation de Terraform

### 6.4.1. Connexion au tenant Azure
Exécuter le commande : 
```
$ az login
```
Cette commande va lancer un navigation pour effectuer une connexion sur Azure.

Mais Il est préférable d'utiliser un "service principal" précédemment créé : 
```
az ad sp create-for-rbac --name "sp-terraform" --role="Contributor" --scopes="/subscriptions/${TF_VAR_subscription_id}"

export CLIENT_ID="xxxxxxxxxxxxxxxxxxxxxxxxxx
export CLIENT_SECRET="yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"
export TENANT_ID="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"

az login --service-principal -u $CLIENT_ID -p $CLIENT_SECRET --tenant $TENANT_ID
```

### 6.4.2. Initialisation du terraform
Cette phase initialise un répertoire de travail contenant les fichiers de configuration de Terraform. Il s'agit de la première commande à exécuter après l'écriture d'une nouvelle configuration Terraform ou le clonage d'une configuration existante.
```
$ terraform init -backend-config "key=<environment>.<nom-du-projet>.tfstate" -reconfigure
```

### 6.4.3. Exécution
Faire un "plan" pour vérifier les modifications :
```
$ terraform plan -var-file terraform.<env>.tfvars
```

Puis faire un "apply" pour les appliquer :
```
$ terraform apply -var-file terraform.<env>.tfvars
```
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```
En  répondant 'yes', vous validerez l'application du code.
