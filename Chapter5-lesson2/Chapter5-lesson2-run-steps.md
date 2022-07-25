# TASK 5.2


# Аутентификация от имени федеративного пользователя (на винде)
`yc init --federation-id=bpfpfctkh7focc85u9sq`
```console
Welcome! This command will take you through the configuration process.

You are going to be authenticated via federation-id 'bpfpfctkh7focc85u9sq'.
Your federation authentication web site will be opened.
After your successful authentication, you will be redirected to cloud console'.

Press 'enter' to continue...
You have one cloud available: 'cloud-praktikumdevopscourse' (id = b1g3jddf4nv5e9okle7p). It is going to be used by default.
Please choose folder to use:
 [1] students-06 (id = b1ggoah947u3kc4j9m7i)
 [2] Create a new folder
Please enter your numeric choice: 1
Your current folder has been set to 'students-06' (id = b1ggoah947u3kc4j9m7i).
Do you want to configure a default Compute zone? [Y/n] y
Which zone do you want to use as a profile default?
 [1] ru-central1-a
 [2] ru-central1-b
 [3] ru-central1-c
 [4] Don't set default zone
Please enter your numeric choice: 1
Your profile default Compute zone has been set to 'ru-central1-a'.
```

# Проверьте настройки вашего профиля CLI
`yc config list`
```console
federation-id: bpfpfctkh7focc85u9sq
cloud-id: b1g3jddf4nv5e9okle7p
folder-id: b1ggoah947u3kc4j9m7i
compute-default-zone: ru-central1-a
```

# Получите IAM-токен
`yc iam create-token`
```console
t1.9euelZrHj8eXis6bmZqTkM_HkcaKie3rnpWajZfNjsiPkpOKnJuVyJSSmp7l8_dzTxVp-e9Uay5H_N3z9zN-Emn571RrLkf8.gSGE6smvQsrK29xy-PLk8YQo89Yxsr_SMjVWn9nfPTPXb9zAeq4lUzFzpQ9lBfUOoQMsVngnBCRGv6rzryl9Dw
```


# Чтобы инициализировать провайдера (на ubuntu)
`terraform init`
```console
Initializing the backend...

Initializing provider plugins...
- Finding yandex-cloud/yandex versions matching "0.61.0"...
- Installing yandex-cloud/yandex v0.61.0...
- Installed yandex-cloud/yandex v0.61.0 (unauthenticated)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```


## Теперь развернём ещё одну ВМ в облаке Яндекса. Для этого допишем в main.tf конфиг новой виртуальной машины:
```yaml
resource "yandex_compute_instance" "vm-1" {
    name = "chapter5-lesson2-dmitriy-pashkov"

    resources {
        cores  = 2
        memory = 2
    }

    boot_disk {
        initialize_params {
            image_id = "fd80qm01ah03dkqb14lc"
        }
    }

    network_interface {
        subnet_id = "e9bq7u62i4q21jq25n5j"
        nat       = false
    }

    metadata = {
        ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
}
```


# Поищем подходящий ID образа, например, 20-й Ubuntu:
`yc compute image list --folder-id standard-images|grep ubuntu-20`
```console
| fd80d7fnvf399b1c207j | ubuntu-20-04-lts-gpu-v20220418                                | ubuntu-2004-lts-gpu                             | f2e3o9ihojuup985m8qc           | READY  |
| fd80jfslq61mssea4ejn | ubuntu-20-04-lts-gpu-v20211217                                | ubuntu-2004-lts-gpu                             | f2epq8rrvl05qks529eh           | READY  |
| fd80lnp0srek01a7cpcu | ubuntu-20-04-lts-vgpu-v20211206                               | ubuntu-2004-lts-vgpu                            | f2e6lfo1lkjc7foq8t76           | READY  |
| fd80qm01ah03dkqb14lc | ubuntu-20-04-lts-vgpu-v20211027                               | ubuntu-2004-lts-vgpu                            | f2ele5h01c3a6d5odmbi           | READY  |
| fd814k6nlgobk70klpjn | ubuntu-20-04-lts-gpu-v20211006                                | ubuntu-2004-lts-gpu                             | f2ekc6jvitdriv4oefho           | READY  |
| fd816r0lmfvlh6r9uos5 | ubuntu-20-04-lts-gpu-a100-v20220502                           | ubuntu-2004-lts-a100                            | f2ecipfqv6n3erhli1h2           | READY  |
| fd818petl0g83pemo5p9 | ubuntu-20-04-lts-gpu-a100-v20220117                           | ubuntu-2004-lts-a100                            | f2ef4tchn4k1bo1v3lep           | READY  |
| fd81d9s0i2thj7sairmc | ubuntu-20-04-lts-gpu-v20220314                                | ubuntu-2004-lts-gpu                             | f2efrqa5kvp0g5lpfal7           | READY  |
| fd81hgrcv6lsnkremf32 | ubuntu-20-04-lts-v20210908                                    | ubuntu-2004-lts                                 | f2e4vkdnbdu1d3abiuto           | READY  |
| fd81n37q9kgufk6rb4c0 | ubuntu-20-04-lts-gpu-v20220307                                | ubuntu-2004-lts-gpu                             | f2e6ft65s6hugbnhqn94           | READY  |
| fd81u2vhv3mc49l1ccbb | ubuntu-20-04-lts-v20220704                                    | ubuntu-2004-lts                                 | f2e92qu6f879vvpe8jad           | READY  |
| fd81v619or2d6kq36jjt | ubuntu-20-04-lts-gpu-a100-v20220321                           | ubuntu-2004-lts-a100                            | f2ejgscd2lu50ijj6cji           | READY  |
| fd823iqr8i3snulnmp90 | ubuntu-20-04-lts-vgpu-v20211103                               | ubuntu-2004-lts-vgpu                            | f2e33jk3o2b57haavm7l           | READY  |
| fd826dalmbcl81eo5nig | ubuntu-20-04-lts-v20220718                                    | ubuntu-2004-lts                                 | f2epkmusmnnkrb9m1vtr           | READY  |
| fd82b8qen6p7dri7kpi7 | ubuntu-20-04-lts-vgpu-v20211201                               | ubuntu-2004-lts-vgpu                            | f2ei7n4jb1nh9snbk8qt           | READY  |
| fd82re2tpfl4chaupeuf | ubuntu-20-04-lts-v20220502                                    | ubuntu-2004-lts                                 | f2eljveqcurh622633be           | READY  |
| fd82su14vvuc8qvauatc | ubuntu-20-04-lts-gpu-a100-v20220711                           | ubuntu-2004-lts-a100                            | f2egvn9075u0krpd4d3m           | READY  |
| fd83klic6c8gfgi40urb | ubuntu-2004-lts-1623345129                                    | ubuntu-2004-lts                                 | f2efrqfcllr7ns1o7b1t           | READY  |
| fd83loj6m93sutjhm4h9 | ubuntu-20-04-lts-gpu-a100-v20210913                           | ubuntu-2004-lts-a100                            | f2eh7qdvf5jje8ebnjns           | READY  |
| fd83mnmdqlojapdpoup3 | ubuntu-20-04-lts-v20211020                                    | ubuntu-2004-lts                                 | f2eti2ij1in47pq86nij           | READY  |
| fd83n3uou8m03iq9gavu | ubuntu-20-04-lts-v20220207                                    | ubuntu-2004-lts                                 | f2e7dln09c42avcbtirs           | READY  |
| fd84qiqr0qmk4os9fglm | ubuntu-20-04-lts-vgpu-v20211213                               | ubuntu-2004-lts-vgpu                            | f2eprq7d1umusvi1ffqu           | READY  |
| fd84rr7fl5qds3l8dnnt | ubuntu-20-04-lts-gpu-a100-v20210915                           | ubuntu-2004-lts-a100                            | f2esqegp6nvuuqqsjo49           | READY  |
| fd861io8oehvvo1vg56j | ubuntu-20-04-lts-gpu-a100-v20220523                           | ubuntu-2004-lts-a100                            | f2ehp7td4jccpftlgn2s           | READY  |
| fd861s4vshkt12tbvld5 | ubuntu-20-04-lts-gpu-a100-v20210924                           | ubuntu-2004-lts-a100                            | f2em6jde9g8lq63p15lm           | READY  |
| fd866giufmdjku2mq8m1 | ubuntu-20-04-lts-gpu-a100-v20220718                           | ubuntu-2004-lts-a100                            | f2eje0pgpn9fdc7v6udk           | READY  |
| fd868ehdk7tpjoi0sn3d | ubuntu-20-04-lts-vgpu-v20211013                               | ubuntu-2004-lts-vgpu                            | f2ebb14pava86nupqa3l           | READY  |
| fd86c2nu8q91ms5fg9p5 | ubuntu-20-04-lts-gpu-v20211227                                | ubuntu-2004-lts-gpu                             | f2e2qvdo3d25irhjef69           | READY  |
| fd86cpunl4kkspv0u25a | ubuntu-20-04-lts-v20220411                                    | ubuntu-2004-lts                                 | f2e1omt88cms6s04srtq           | READY  |
| fd86qh4o64oprn8i60i3 | ubuntu-20-04-lts-gpu-a100-v20211006                           | ubuntu-2004-lts-a100                            | f2eb15npv6mk0p15c8lk           | READY  |
| fd86qp46m631lci0347o | ubuntu-2004-lts-gpu-1612390480                                | ubuntu-2004-lts-gpu                             | f2e1ksi0qnfjkhi83h44           | READY  |
| fd86t95gnivk955ulbq8 | ubuntu-20-04-lts-v20220509                                    | ubuntu-2004-lts                                 | f2ecfju2g0fri0pesgeq           | READY  |
| fd875chduv5t5k8r3914 | ubuntu-20-04-lts-gpu-a100-v20211020                           | ubuntu-2004-lts-a100                            | f2elcmg9kc8egoaqt36a           | READY  |
| fd877sidh4gajam1r7vn | ubuntu-20-04-lts-gpu-v20220328                                | ubuntu-2004-lts-gpu                             | f2emohgb3hl0sle1886v           | READY  |
| fd879gb88170to70d38a | ubuntu-20-04-lts-v20220404                                    | ubuntu-2004-lts                                 | f2etas6dbq2is1l8lp50           | READY  |
| fd87m5d5vkfsf6eap2om | ubuntu-20-04-lts-gpu-v20220404                                | ubuntu-2004-lts-gpu                             | f2e470jfaq4dphc0b82q           | READY  |
| fd87mmcfmlio7r0av2n7 | ubuntu-20-04-lts-gpu-v20220128                                | ubuntu-2004-lts-gpu                             | f2ekmcabqvjp1oo2sqd3           | READY  |
| fd87tirk5i8vitv9uuo1 | ubuntu-20-04-lts-v20220606                                    | ubuntu-2004-lts                                 | f2e8tnsqjeor74blquqc           | READY  |
| fd87uq4tagjupcnm376a | ubuntu-2004-lts-1612358882                                    | ubuntu-2004-lts                                 | f2e2omleq2p9hqm60avu           | READY  |
| fd87vtgedoo2ogrcuvlr | ubuntu-20-04-lts-gpu-a100-v20210929                           | ubuntu-2004-lts-a100                            | f2elsg3ff7a8skrae5r0           | READY  |
| fd881mklmg58pgfv8csm | ubuntu-20-04-lts-gpu-a100-v20211027                           | ubuntu-2004-lts-a100                            | f2e7iu63q5dhvo900g8j           | READY  |
| fd887d355htae3j8ttgq | ubuntu-20-04-lts-vgpu-v20211110                               | ubuntu-2004-lts-vgpu                            | f2ehj6igppifta73edtr           | READY  |
| fd89boblh6d5vruo39lm | ubuntu-20-04-lts-v20211201                                    | ubuntu-2004-lts                                 | f2e847kqk689mvfkmfbo           | READY  |
| fd89eo5pqp5jkkqlp5ac | ubuntu-20-04-lts-gpu-a100-v20211124                           | ubuntu-2004-lts-a100                            | f2eq078cng4grf06un9d           | READY  |
| fd89ka9p6idl8htbmhok | ubuntu-20-04-lts-v20220124                                    | ubuntu-2004-lts                                 | f2eei02oardlpedocvan           | READY  |
| fd89ovh4ticpo40dkbvd | ubuntu-20-04-lts-v20220530                                    | ubuntu-2004-lts                                 | f2ek1vhoppg2l2afslmq           | READY  |
| fd8a2e4ugj8178dmqen9 | ubuntu-20-04-lts-gpu-a100-v20211117                           | ubuntu-2004-lts-a100                            | f2euscu6gci5sunu1rb6           | READY  |
| fd8ak7j21nof8qq1h7jf | ubuntu-20-04-lts-gpu-v20220207                                | ubuntu-2004-lts-gpu                             | f2eivsn8tiuulssim7kb           | READY  |
| fd8anitv6eua45627i0e | ubuntu-20-04-lts-v20220418                                    | ubuntu-2004-lts                                 | f2ema6pmtbjl2kmcjlbv           | READY  |
| fd8avqejtkvjtinua84f | ubuntu-20-04-lts-gpu-v20211013                                | ubuntu-2004-lts-gpu                             | f2e4nc5hhk586udqfder           | READY  |
| fd8b73n27kjb22d5b7ud | ubuntu-20-04-lts-gpu-a100-v20211227                           | ubuntu-2004-lts-a100                            | f2ec4ah8gjbte6ecrdia           | READY  |
| fd8ba0ukgkn46r0qr1gi | ubuntu-20-04-lts-v20220117                                    | ubuntu-2004-lts                                 | f2e0m9t25irr79kalsdn           | READY  |
| fd8bfmkt64o90eu4pksv | ubuntu-20-04-lts-gpu-a100-v20220418                           | ubuntu-2004-lts-a100                            | f2ekuut0u3c1hapt6o62           | READY  |
| fd8c40htn5g3o8s1sbuf | ubuntu-20-04-lts-gpu-a100-v20220704                           | ubuntu-2004-lts-a100                            | f2e7pk3l5tm4ph3hh5g2           | READY  |
| fd8ciuqfa001h8s9sa7i | ubuntu-20-04-lts-v20220523                                    | ubuntu-2004-lts                                 | f2eupbrht1hd5ooqe9ec           | READY  |
| fd8cuq254pag9t4pkasb | ubuntu-20-04-lts-gpu-a100-v20220516                           | ubuntu-2004-lts-a100                            | f2epn54be1pel4cjffv3           | READY  |
| fd8d0hgn3v38aplddbkv | ubuntu-20-04-lts-vgpu-v20211006                               | ubuntu-2004-lts-vgpu                            | f2e48ath8233usnmclfa           | READY  |
| fd8db2s90v5knmg1p7dv | ubuntu-20-04-lts-v20211006                                    | ubuntu-2004-lts                                 | f2eil5udr0p4k13o7qc9           | READY  |
| fd8de05o2rq7e4bbao95 | ubuntu-2004-lts-vgpu-1617618947                               | ubuntu-2004-lts-vgpu                            | f2e76u54kgejjmvgaltf           | READY  |
| fd8djorn1i83kd7ql01q | ubuntu-20-04-lts-vgpu-v20211117                               | ubuntu-2004-lts-vgpu                            | f2e8ve1s6ipk4qh5umeo           | READY  |
| fd8djv1vmpfdkn5eporh | ubuntu-20-04-lts-gpu-a100-v20220411                           | ubuntu-2004-lts-a100                            | f2ekavtamkfihh1c70uu           | READY  |
| fd8etnr6krbm4llmjgtn | ubuntu-20-04-lts-v20210811                                    | ubuntu-2004-lts                                 | f2e8jtqb9uh4hc1ftmll           | READY  |
| fd8eu5tslhldv9j29akp | ubuntu-20-04-lts-gpu-v20220214                                | ubuntu-2004-lts-gpu                             | f2eh9nd23blmm646c7qo           | READY  |
| fd8f1tik9a7ap9ik2dg1 | ubuntu-20-04-lts-v20220620                                    | ubuntu-2004-lts                                 | f2eu4hp2k4r04d1usuh3           | READY  |
| fd8f30hur3255mjfi3hq | ubuntu-20-04-lts-v20211220                                    | ubuntu-2004-lts                                 | f2eds5lpj5spivf93dkt           | READY  |
| fd8f8p0q2duoaff2985h | ubuntu-20-04-lts-gpu-a100-v20220404                           | ubuntu-2004-lts-a100                            | f2eq2gnvufl06ck56geu           | READY  |
| fd8fbgvdt6mktnprvo89 | ubuntu-20-04-lts-v20210811a                                   | ubuntu-2004-lts                                 | f2er2cc89e252lj4bf5o           | READY  |
| fd8fh5he9b41fm3uuj1b | ubuntu-20-04-lts-gpu-a100-v20220606                           | ubuntu-2004-lts-a100                            | f2ehvtaktpen71lf32gh           | READY  |
| fd8firhksp7daa6msfes | ubuntu-20-04-lts-v20210929                                    | ubuntu-2004-lts                                 | f2e6fnj3erf1sropamjr           | READY  |
| fd8fte6bebi857ortlja | ubuntu-20-04-lts-v20211227                                    | ubuntu-2004-lts                                 | f2eh8sclblvdlq7iarqv           | READY  |
```


# Выведем список подсетей:
`yc vpc subnets list`
```console
+----------------------+-----------------------+----------------------+----------------+---------------+-----------------+
|          ID          |         NAME          |      NETWORK ID      | ROUTE TABLE ID |     ZONE      |      RANGE      |
+----------------------+-----------------------+----------------------+----------------+---------------+-----------------+
| b0c2vkc4fu5n7m6k1pk3 | default-ru-central1-c | enplibkhb5estnhe9l35 |                | ru-central1-c | [10.130.0.0/24] |
| e2l8eqsgt5somamlorff | default-ru-central1-b | enplibkhb5estnhe9l35 |                | ru-central1-b | [10.129.0.0/24] |
| e9bq7u62i4q21jq25n5j | default-ru-central1-a | enplibkhb5estnhe9l35 |                | ru-central1-a | [10.128.0.0/24] |
+----------------------+-----------------------+----------------------+----------------+---------------+-----------------+
```


# линтер для проверки написания main.tf
`terraform validate`


# запуск терраформа
`terraform apply`
```console
yandex_compute_instance.vm-1: Creating...
yandex_compute_instance.vm-1: Still creating... [10s elapsed]
yandex_compute_instance.vm-1: Creation complete after 20s [id=fhm7qqsf792svfh461uk]
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```


# Add IP
```console
# Add cloud provider Yandex.Cloud
terraform {
 required_providers {
  yandex = {
  source  = "yandex-cloud/yandex"
  version = "0.61.0"
  }
 }
}

provider "yandex" {
 token     = "t1.9euelZrHj8eXis6bmZqTkM_HkcaKie3rnpWajZfNjsiPkpOKnJuVyJSSmp7l8_dzTxVp-e9Uay5H_N3z9zN-Emn571RrLkf8.gSGE6smvQsrK29xy-PLk8YQo89Yxsr_SMjVWn9nfPTPXb9zAeq4lUzFzpQ9lBfUOoQMsVngnBCRGv6rzryl9Dw"
 cloud_id  = "b1g3jddf4nv5e9okle7p"
 folder_id = "b1ggoah947u3kc4j9m7i"
 zone      = "ru-central1-a"
}

# Create VM
resource "yandex_compute_instance" "vm-1" {
    name = "chapter5-lesson2-dmitriy-pashkov"

    resources {
        cores  = 2
        memory = 2
    }

    boot_disk {
        initialize_params {
            image_id = "fd80qm01ah03dkqb14lc"
        }
    }

    network_interface {
        subnet_id = "e9bq7u62i4q21jq25n5j"
        nat       = false
    }

    metadata = {
        ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
}

# Get IP
output "ip_address" {
    value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

# output
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
Outputs:
ip_address = "10.128.0.126"
```


`ssh ubuntu@10.128.0.126`
```console
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-42-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
Failed to connect to https://changelogs.ubuntu.com/meta-release-lts. Check your Internet connection or proxy settings

Last login: Fri Jul 22 14:01:30 2022 from 10.128.0.60
```

`terraform validate`
```console
Success! The configuration is valid.
```

`terraform fmt`
```console
main.tf
```

`terraform apply --auto-approve`
```console
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # yandex_compute_instance.vm-1 will be created
  + resource "yandex_compute_instance" "vm-1" {
      + created_at                = (known after apply)
      + folder_id                 = (known after apply)
      + fqdn                      = (known after apply)
      + hostname                  = (known after apply)
      + id                        = (known after apply)
      + metadata                  = {
          + "serial-port-enable" = "1"
          + "user-data"          = <<-EOT
                #cloud-config
                users:
                  - name: ansible
                    groups: sudo
                    shell: /bin/bash
                    sudo: ['ALL=(ALL) NOPASSWD:ALL']
                    shell: /bin/bash
                    ssh_authorized_keys:
                      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbe0dgBa3lFqSYyELOTj9uNFDD07u1rPHUyDI5VUmopPabU3EtyaOKNj+4ye/PUt2iv9Vu2WTbHVbj9SmJaApVI0GCHMY3NrXI+BUguSnKjtecpi4BSiJN6uUxmVHUNHbkWGuoOBX5oo+6fK8s5ne36QywL04HJmvtDQS9/wb1JUq0WOH8GR5kWHXvqtRs7vLzeVNH3BFYM+9tuNNBTVY3+AHs2vZH90S/EbwML4JttxwHgz/ZZ6CCCPrTGBZhroDNGL2dqhRGS01N+UHVUNO0nt8+CaGjwot43agboW3gEguMMjiHfFiNXgnCVEMJIGKJDqE2VGHo5AQ5gh+y6v+r student@fhmfcr5pto87rkevkqmj
            EOT
        }
      + name                      = "chapter5-lesson2-dmitriy-pashkov-vm-1"
      + network_acceleration_type = "standard"
      + platform_id               = "standard-v1"
      + service_account_id        = (known after apply)
      + status                    = (known after apply)
      + zone                      = (known after apply)

      + boot_disk {
          + auto_delete = true
          + device_name = (known after apply)
          + disk_id     = (known after apply)
          + mode        = (known after apply)

          + initialize_params {
              + description = (known after apply)
              + image_id    = "fd80qm01ah03dkqb14lc"
              + name        = (known after apply)
              + size        = (known after apply)
              + snapshot_id = (known after apply)
              + type        = "network-hdd"
            }
        }

      + network_interface {
          + index              = (known after apply)
          + ip_address         = (known after apply)
          + ipv4               = true
          + ipv6               = (known after apply)
          + ipv6_address       = (known after apply)
          + mac_address        = (known after apply)
          + nat                = true
          + nat_ip_address     = (known after apply)
          + nat_ip_version     = (known after apply)
          + security_group_ids = (known after apply)
          + subnet_id          = "e9bq7u62i4q21jq25n5j"
        }

      + placement_policy {
          + placement_group_id = (known after apply)
        }

      + resources {
          + core_fraction = 100
          + cores         = 2
          + memory        = 2
        }

      + scheduling_policy {
          + preemptible = (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + external_ip_address = (known after apply)
  + internal_ip_address = (known after apply)
yandex_compute_instance.vm-1: Creating...
yandex_compute_instance.vm-1: Still creating... [10s elapsed]
yandex_compute_instance.vm-1: Still creating... [20s elapsed]
yandex_compute_instance.vm-1: Creation complete after 22s [id=fhm1he3tlquolo4ei9fg]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address = "51.250.81.23"
internal_ip_address = "10.128.0.130"
```


`ssh ansible@51.250.81.23`
```console
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-42-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ansible@fhm1he3tlquolo4ei9fg:~$ pwd
/home/ansible
ansible@fhm1he3tlquolo4ei9fg:~$ cd ..
ansible@fhm1he3tlquolo4ei9fg:/home$ ls
ansible
ansible@fhm1he3tlquolo4ei9fg:/home$ whoami
ansible
ansible@fhm1he3tlquolo4ei9fg:/home$
```

`terraform destroy --auto-approve`
```console
yandex_compute_instance.vm-1: Refreshing state... [id=fhm1he3tlquolo4ei9fg]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # yandex_compute_instance.vm-1 will be destroyed
  - resource "yandex_compute_instance" "vm-1" {
      - created_at                = "2022-07-25T10:08:32Z" -> null
      - folder_id                 = "b1ggoah947u3kc4j9m7i" -> null
      - fqdn                      = "fhm1he3tlquolo4ei9fg.auto.internal" -> null
      - hostname                  = "fhm1he3tlquolo4ei9fg" -> null
      - id                        = "fhm1he3tlquolo4ei9fg" -> null
      - labels                    = {} -> null
      - metadata                  = {
          - "serial-port-enable" = "1"
          - "user-data"          = <<-EOT
                #cloud-config
                users:
                  - name: ansible
                    groups: sudo
                    shell: /bin/bash
                    sudo: ['ALL=(ALL) NOPASSWD:ALL']
                    shell: /bin/bash
                    ssh_authorized_keys:
                      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbe0dgBa3lFqSYyELOTj9uNFDD07u1rPHUyDI5VUmopPabU3EtyaOKNj+4ye/PUt2iv9Vu2WTbHVbj9SmJaApVI0GCHMY3NrXI+BUguSnKjtecpi4BSiJN6uUxmVHUNHbkWGuoOBX5oo+6fK8s5ne36QywL04HJmvtDQS9/wb1JUq0WOH8GR5kWHXvqtRs7vLzeVNH3BFYM+9tuNNBTVY3+AHs2vZH90S/EbwML4JttxwHgz/ZZ6CCCPrTGBZhroDNGL2dqhRGS01N+UHVUNO0nt8+CaGjwot43agboW3gEguMMjiHfFiNXgnCVEMJIGKJDqE2VGHo5AQ5gh+y6v+r student@fhmfcr5pto87rkevkqmj
            EOT
        } -> null
      - name                      = "chapter5-lesson2-dmitriy-pashkov-vm-1" -> null
      - network_acceleration_type = "standard" -> null
      - platform_id               = "standard-v1" -> null
      - status                    = "running" -> null
      - zone                      = "ru-central1-a" -> null

      - boot_disk {
          - auto_delete = true -> null
          - device_name = "fhm42abfra6tftrh1tvs" -> null
          - disk_id     = "fhm42abfra6tftrh1tvs" -> null
          - mode        = "READ_WRITE" -> null

          - initialize_params {
              - image_id = "fd80qm01ah03dkqb14lc" -> null
              - size     = 30 -> null
              - type     = "network-hdd" -> null
            }
        }

      - network_interface {
          - index              = 0 -> null
          - ip_address         = "10.128.0.130" -> null
          - ipv4               = true -> null
          - ipv6               = false -> null
          - mac_address        = "d0:0d:18:b8:7d:ae" -> null
          - nat                = true -> null
          - nat_ip_address     = "51.250.81.23" -> null
          - nat_ip_version     = "IPV4" -> null
          - security_group_ids = [] -> null
          - subnet_id          = "e9bq7u62i4q21jq25n5j" -> null
        }

      - placement_policy {}

      - resources {
          - core_fraction = 100 -> null
          - cores         = 2 -> null
          - gpus          = 0 -> null
          - memory        = 2 -> null
        }

      - scheduling_policy {
          - preemptible = false -> null
        }
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  - external_ip_address = "51.250.81.23" -> null
  - internal_ip_address = "10.128.0.130" -> null
yandex_compute_instance.vm-1: Destroying... [id=fhm1he3tlquolo4ei9fg]
yandex_compute_instance.vm-1: Still destroying... [id=fhm1he3tlquolo4ei9fg, 10s elapsed]
yandex_compute_instance.vm-1: Destruction complete after 12s

Destroy complete! Resources: 1 destroyed.
```
