# Laporan Sementara Modul 1

## Nomor 1

---
![Topology Nomor 1](assets/no1topology.png)

Router (lain) disini menggunakan debinet

config di router :
Konfigurasi IP tersebut dimasukkan pada *router* sebagai berikut (prefix kelompok adalah 10.82.x.x):

```bash
# Config eth1
auto eth1
iface eth1 inet static
    address 10.82.1.1
    netmask 255.255.255.0

# Config eth2
auto eth2
iface eth2 inet static
    address 10.82.2.1
    netmask 255.255.255.0

# Config eth3
auto eth3
iface eth3 inet static
    address 10.82.3.1
    netmask 255.255.255.0
```

Bukti kalau router sudah berhasil meneruskan data antar switch (subnet) Disini VPCS Alice melakukan ping ke IP nya VPCS Chisa:
![alicepingchisa](assets/1-alicepingchisa.png)

## Nomor 2

---

![nat added to topology](assets/2-nattopology.png)

(NAT menggunakan eth0 di router sesuai instruksi pada soal)

Config di router untuk NAT:

```bash
# Config eth0 
auto eth0
iface eth0 inet dhcp
    up sysctl -w net.ipv4.ip_forward=1
    up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```
Bukti berhasilnya terhubung:
![alt text](image.png)


## Nomor 3

Diminta untuk memastikan seluruh client yang berada di bawah Switch 1, Switch 2, dan Switch 3 dapat saling terhubung dan berkomunikasi setelah router terhubung ke internet.

Dikarenakan di config router tadi sudah menambahkan

```bash
up sysctl -w net.ipv4.ip_forward=1
```

Dimana perinah ini berguna memang untuk memforward routing dari satu client ke client lainnya.
Dan juga, di seluruh client sudah di atur ip nya sesuai dengan prefix (10.82.x.1).

![Bukti Ping Mika](assets/3-switch1.png)
![Bukti Ping Chisa](assets/3-switch2.png)
![Bukti Ping Knights](assets/3-switch3.png)

10.82.1.2 = Switch 1
10.82.2.2 = Switch 2
10.82.3.2 = Switch 3

Mika kan berada di switch 1 jadi dilakukan ping untuk ip switch 2 dan 3, begitu juga yang lainnya, dilakukan ping untuk mengecek koneksi di switch yang lain

## Nomor 4

---

Untuk NAT Masquerades sudah di setup sebelumnya di router

```bash
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

Tinggal bagian DNS Resolver,
![Mika](assets/4-mika.png)

Awalnya dicoba untuk ping google.com dan ternyata masih belum bisa, lalu dilakukan pemasangan DNS resolver dengan cara memasukkan command
```bash
ip dns 8.8.8.8
```
Setelah itu coba ping google.com dan sudah berhasil

Bukti untuk client lainnya:
![Alice](assets/4-alice.png)
![Chisa](assets/4-chisa.png)
![Eiri](assets/4-eiri.png)
![Knights](assets/4-knights.png)
