# Jarkom-Modul-1-2026-K-37

| Nama  | NRP  |
|---|---|
| Gede Satya Putra Aryanta   |  5027251012 |
|  Azfaro Zid Ilmi | 5027251018  |





# Laporan Sementara Modul 1

## Nomor 1

---
![Topology Nomor 1](assets/1-topology.png)

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

Setiap *client* juga diatur IP statisnya melalui file `/etc/network/interfaces` di masing-masing *node*.
Bukti kalau router sudah berhasil meneruskan data antar switch (subnet). Di sini, *client* Alice melakukan ping ke IP *client* Chisa:
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

Diminta untuk memastikan seluruh *client* yang berada di bawah Switch 1, Switch 2, dan Switch 3 dapat saling terhubung dan berkomunikasi setelah router terhubung ke internet.

Dikarenakan di config router tadi sudah menambahkan:

```bash
up sysctl -w net.ipv4.ip_forward=1
```

Dimana perintah ini berguna untuk mem-forward routing dari satu *client* ke *client* lainnya.
Dan juga, di seluruh *client* sudah diatur IP statisnya beserta *gateway* yang mengarah ke router (10.82.x.1) melalui file konfigurasi `/etc/network/interfaces`.

![Bukti Ping Mika](assets/3-switch1.png)
![Bukti Ping Chisa](assets/3-switch2.png)
![Bukti Ping Knights](assets/3-switch3.png)

Keterangan konfigurasi IP *Client*:
- 10.82.1.2 = Client pada Switch 1 (Mika)
- 10.82.2.2 = Client pada Switch 2 (Chisa)
- 10.82.3.2 = Client pada Switch 3 (Knights)

Mika kan berada di switch 1 jadi dilakukan ping untuk ip switch 2 dan 3, begitu juga yang lainnya, dilakukan ping untuk mengecek koneksi di switch yang lain


## Nomor 4

---

Untuk NAT Masquerade sudah di-setup sebelumnya di router:

```bash
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

Tinggal bagian DNS Resolver:
![Mika](assets/4-mika.png)

Awalnya dicoba untuk ping google.com dan ternyata masih belum bisa. Lalu dilakukan pemasangan DNS resolver dengan memodifikasi file `/etc/resolv.conf` pada setiap *client* berbasis Linux (Alpine/Debian) menggunakan *command*:
```bash
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```

Setelah itu coba ping google.com kembali dan sudah berhasil.

Bukti untuk client lainnya:
![Alice](assets/4-alice.png)
![Chisa](assets/4-chisa.png)
![Eiri](assets/4-eiri.png)
![Knights](assets/4-knights.png)

## Nomor 5

---

Diminta untuk mengantisipasi restart tiba-tiba pada node dengan memastikan konfigurasi jaringan (IP dan aturan NAT) bersifat persisten, serta membuat script pengecekan otomatis.

Karena konfig IP dan commmand menambahkan iptables (NAT) telah dimasukkan ke dalam file `/etc/network/interfaces` di router Lain (seperti yang ditunjukkan pada Nomor 1 dan 2), maka konfig tersebut dipastikan tidak akan hilang meskipun router di reboot.

Untuk cek status secara cepat, kami membuat script bash di `/root/cek_status.sh` pada router Lain. 

Isinya adalah:
```bash
echo '#!/bin/bash' > /root/cek_status.sh
echo 'ip -br a' >> /root/cek_status.sh
echo 'iptables -t nat -L -v -n' >> /root/cek_status.sh
chmod +x /root/cek_status.sh
```

Setelah router direstart, kami menjalankan script tersebut dengan mengeksekusi `/root/cek_status.sh`. Berikut adalah tangkapan layar bukti eksekusinya yang memperlihatkan daftar IP setiap interface (`ip -br a`) serta status tabel NAT yang memuat aturan MASQUERADE (`iptables -t nat -L -v -n`):

![Bukti Cek Status Router Lain](assets/5-cekstatus.png)

## Nomor 6

---

Filter yang digunakan adalah:
dns or icmp

Berikut adalah tangkapan layar dari hasil penyaringan Wireshark:

![Hasil Filter Wireshark Mika](assets/6-wireshark.png)

Terdapat beberapa paket yang muncul dari filter:
- Paket DNS: Terdapat aktivitas Standard query response untuk berbagai domain, seperti its.ac.id, github.com, cloudflare.com, dan google.com.
- Paket ICMP: Terdapat aktivitas pengiriman Echo (ping) request dan penerimaan Echo (ping) reply yang mengarah ke alamat IP publik seperti 8.8.8.8 dan 1.1.1.1.


## Nomor 7

---

Akses yang harus diterapkan adalah:
- alice memiliki hak akses read dan write.
- mika dibatasi hanya read-only.
- eiri dibatasi tanpa izin akses sama sekali (blacklist).

1. instal vsFTPd di chisa
2. bikin directory /var/wired/data
```bash
apt-get update
apt-get install vsftpd -y
mkdir -p /var/wired/data
```
3. bikin ketiga user tersebut 
```bash
useradd -d /var/wired/data -s /bin/bash alice
passwd alice

useradd -d /var/wired/data -s /bin/bash mika
passwd mika

useradd -d /var/wired/data -s /bin/bash eiri
passwd eiri
```


Untuk mengatur hak akses read dan write,
```bash
chown alice:alice /var/wired/data
```
 Sedangkan permission foldernya diatur menjadi 755 agar user lain hanya bisa read dan execute, tanpa write.

 ```bash
chmod 755 /var/wired/data
 ```

next, config vsftpd untuk mengizinkan akses write dan memblokir segala akses
```bash
cat << 'EOF' > /etc/vsftpd.conf
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
allow_writeable_chroot=YES
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=YES
EOF
```

Lalu add eiri ke blocklist

```bash
echo "eiri" > /etc/vsftpd.userlist
service vsftpd restart
```

Bukti eiri sudah ditolak: 
![Bukti Akses Ditolak Eiri](assets/7-eiri.png)

Bukti Alice punya akses write:

![Bukti Upload File Alice](assets/7-alice.png)

## Nomor 8

---

Jadi disini disuruh melakukan FTP client dari Knights ke FTP Server Chisa menggunakan akun alice.

digunakan dengan command
```bash
put knights_report.txt
```

Berikut screenshot wireshark setelah dilakukannya put:

![Analisis Wireshark Upload FTP Knights](assets/8-wireshark.png)

Dapat ditemukan:
- Ketika mengirimkan command put, Knights mengirimkan request STOR.
- Setelah transfer selesai, server merespons demgan kode 226.
- Setelah mengirimkan command put namun sebelum mengirimkan request STOR, server memasuki Extended Passive Mode (|||11491|) yang menunjukkan kalau port TCP yang digunakan adalah port 11491 untuk proses FTP ini

## Nomor 9

---

Untuk memvalidasi konfigurasi read-only pada user mika, dilakukan pengujian akses FTP dari node Mika ke server Chisa.

1. Dilakukan pengujian get, seharusnya bisa karena semuanya default punya akses read.
Buktinya:
![Bukti Unduh Mika](assets/9-mikaget.png)

2. Dilakukan pengujian put, seharusnya tidak bisa karena yang punya akses write hanya Alice


![Bukti Gagal Unggah Mika](assets/9-mikaput.png)

Namun pesan error yang muncul bukan error 550 permission denied, melainkan 553 could not create file
## Nomor 10

---

Command yang dieksekusi di node Knights adalah:
ping -c 77 -s 128 -i 0.3 10.82.2.2

Berikut adalah hasil statistik dari terminal Knights:

![Statistik Ping Terminal](assets/10-terminal.png)

Berdasarkan hasil di terminal, dapat dianalisis bahwa:
- Packet Loss: Terjadi 0% packet loss (77 paket dikirim dan 77 paket diterima), yang berarti jaringan sangat stabil dan tidak ada paket yang hilang.
- RTT (Round Trip Time): Waktu tempuh minimum (min) adalah 0.438 ms, rata-rata (avg) adalah 0.612 ms, dan maksimum (max) adalah 1.124 ms.

Selain itu, dilakukan analaisis untuk paket request dan reply di wireshark:

![ICMP Echo Request](assets/10-request.png)
Dari gambar di atas, pada saat node Knights mengirimkan paket (Echo request) ke Chisa, nilai ICMP Type yang digunakan adalah 8 dan Code-nya adalah 0.

![ICMP Echo Reply](assets/10-reply.png)
Sedangkan saat server Chisa membalas (Echo reply) ke node Knights, nilai ICMP Type yang digunakan adalah 0 dan Code-nya adalah 0.

## Nomor 11

---

Install telnet terlebih dahulu
```bash
apt-get install telnetd -y
useradd -m -s /bin/bash phantom_user passwd phantom_user
```
lalu masukkan wired_ghost saat diminta password.

Lalu coba login dari terminal eiri sembari mengcapture packet nya.

install telnet juga di eiri lalu lakukan koneksi telnet
```bash
telnet 10.82.2.2
```

masukkan username dan password yang tadi.

Lalu masuk ke wireshark dan filter untuk telnet, lakukan follow TCP stream pada salah satu paket sesuai instruksi di soal

![Bukti Telnet Plain Text](assets/11-telnet.png)

Dari hasil tangkapan tersebut, terdapat dua hal yang dapat disimpulkan:
1. Kredensial Plain Text: Telnet tidak menggunakan enkripsi sama sekali, bisa dilihat password dan usernamenya.
2. Karakter Dikirim Terpisah: Karena kan server mengirim teks username:, lalu menunggu input Anda. Karena username bukan informasi rahasia, karakter yang Anda ketik akan ditampilkan (echo) di layar. Kelihatan juga tiap huruf muncul double dan warnanya beda, karena warna merah muncul terlebih dahulu, berarti itu input dari kita, sedangkan yang warna biru merupakan echo dari server untuk ditampilin lagi di layar kita, sedangkan untuk password tidak di echo makanya munculnya tidak terpisah

## Nomor 12

---

Install netcat terlebih dahulu di node knights:
```bash
apt-get update 
apt-get install openssh-server -y service ssh start
```
lalu buka port 80:
```bash
nc -l -p 80 &
```

Selanjutnya start capture di kabel node Alice, lalu di terminalnya run command untuk memindai port-port yang sesuai dengan di soal (22,80,7777)

```bash
nc -zv 10.82.3.2 22 80 7777
```

Screenshot Wireshark yang membandingkan respons ketiga port tersebut:

![Pemindaian Netcat Alice ke Knights](assets/12-netcat.png)

Analisis:
- Port Terbuka (Port 22 dan Port 80): Hal ini menandakan bahwa server menerima permintaan koneksi dan siap untuk melanjutkan proses three-way handshake pada port yang terbuka (dalam kasus ini port SSH dan Netcat)
- Port Tertutup (Port 7777): Server Knights langsung merespons dengan flag [RST, ACK]. Flag RST (Reset) ini berfungsi memutuskan koneksi karena tidak ditemukannya device di port itu (port tertutup).

## Nomor 13

---

1. Siapkan akun di Knights
```bash
useradd -m -s /bin/bash mika_admin passwd mika_admin
```
2. Buat ssh key di mika lalu kirim ke knights
```bash
ssh-keygen
```

```bash
ssh-copy-id mika_admin@10.82.3.2
```

3. Matikan fitur login password agar hanya bisa login pakai ssh key yang baru saja dikirim

```bash
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config 
service ssh restart
```

Lalu untuk pembuktiannya di wireshark:

1. Start capture dulu
2. Di terminal Mika, login ssh menggunakan `ssh mika_admin@10.82.3.2` (seharusnya langsung masuk ke terminal knights tanpa ditanya password)
3. Cari paket sshv2 di wireshark 

![Analisis Wireshark SSH](assets/13-ssh.png)

Dari analisis Wireshark, dapat terlihat jelas perbedaan mendasar antara SSH dan Telnet:
- Protocol Version Exchange: Pada awal koneksi, terlihat paket "Client: Protocol" dan "Server: Protocol" di mana kedua belah pihak verifikasi versi SSH yang digunakan (SSH-2.0-OpenSSH).
- Key Exchange Init: Setelah versi diverifikasi, client dan server segera melakukan Key Exchange Init untuk membangun encrypted tunnel.
- Kredensial Terenkripsi: Tidak seperti Telnet yang mengirimkan kredensial secara plain text, kredensial pada SSH (mika_admin) tidak dapat dibaca di Wireshark. Seluruh proses pertukaran data dibungkus di dalam encrypted tunnel.



## 14. Web Brute Force

Menganalisis lalu lintas HTTP pada file capture untuk mengidentifikasi alamat IP penyerang, alamat IP target, port yang diserang, password yang berhasil digunakan, serta informasi web server.


<img src="assets/14-bruteforce.png" width="500">


Hasil
```text
IP Penyerang: 172.26.7.50
IP Target: 172.26.7.100
Port Target: 8080
```
<img src="assets/14-password.png" width="400" >

Pada bagian File Data terlihat:

```text
username = lain_admin
password = wired_pr0tocol_7
```
Request tersebut kemudian mendapatkan response pada Frame 351 dengan  menunjukkan bahwa request pada Frame 350 mendapatkan response berhasil.

<img src="assets/14-port.png" width="200">

Hasil
```text
Username: lain_admin
Password: wired_pr0tocol_7
Request: Frame 350
Response: Frame 351
Status Code: 200 OK
Web Server: Apache
Versi: 2.4.62
```


### Validasi Socket Server

<img src="assets/14-socket.png" width="500">

Memvalidasi hasil analisis brute-force HTTP, seperti IP target, port yang diserang, dan informasi login.

## 15. Analisis wired_usb_hid.pcap

Pada proses USB device enumeration, dilakukan analisis terhadap paket GET DESCRIPTOR Response DEVICE. Dari bagian Device Descriptor diperoleh:

<img src="assets/15-wired.png" width="300">


| Parameter  | Hasil    |
| ---------- | -------- |
| Vendor ID  | `0x046d` |
| Product ID | `0xc31c` |

Device tersebut teridentifikasi sebagai perangkat keyboard Logitech.
### device adress
<img src="assets/15-address0.png" width="300">

<img src="assets/15-address7.png" width="300">

Pada paket USB HID yang membawa data input keyboard, ditemukan Device Address 7. Address 0 muncul pada tahap awal proses enumeration, sedangkan komunikasi HID selanjutnya menggunakan address 7.

### analisis input keyboard


Paket input keyboard dapat ditemukan pada paket URB_INTERRUPT in. Salah satu contoh data yang diperoleh:
```text
02 00 1a 00 00 00 00 00
```
<img src="assets/15-address7.png" width="300">

Byte pertama (02) merupakan modifier Left Shift, sedangkan byte ketiga (1a) merupakan keycode. Berdasarkan pemetaan HID keyboard, keycode tersebut merepresentasikan huruf W, sehingga kombinasi tersebut menghasilkan W. Paket dengan keycode 00 merupakan report tanpa tombol yang ditekan/release report, sehingga tidak diterjemahkan sebagai karakter.

### Kata Rahasia

Dengan membaca keycode non-zero pada paket-paket URB_INTERRUPT in secara berurutan dan menerjemahkannya ke karakter keyboard, diperoleh:
```bash
wired_protocol_7_is_alive_2026
```
### socked server
<img src="assets/15-socket.png" width="500">

Memvalidasi hasil analisis USB HID, terutama alamat/device address keyboard dan pesan dari keystroke.

## 16. Analisis FTP Theft

Berdasarkan analisis file wired_ftp_theft.pcap, ditemukan bahwa server FTP penyerang menggunakan vsftpd versi 3.0.5. Proses autentikasi menggunakan username knights_agent dengan password N4v1_s3cur3_2026 dan mendapatkan respons 230 Login successful. File malware knights_payload.exe kemudian diakses menggunakan perintah RETR. Ukuran file diketahui sebesar 524288 bytes berdasarkan respons SIZE dengan kode 213.

<img src="assets/16-ftp.png" width="350">


| Parameter                   | Hasil                 |
| --------------------------- | --------------------- |
| IP Server FTP Penyerang | 198.51.100.7        |
| FTP Software/Banner     | vsftpd 3.0.5        |
| Username                | knights_agent       |
| Password                | N4v1_s3cur3_2026    |
| Nama File Malware       | knights_payload.exe |
| Ukuran File             | 524288 bytes        |


### socked server
<img src="assets/16-socket.png" width="500">

Memvalidasi hasil analisis FTP, seperti server FTP, kredensial, software/banner, dan ukuran file.

## 17 HTTP C2
 ditemukan adanya komunikasi HTTP antara sistem Alice dengan server yang digunakan untuk mengunduh payload. Pada Frame 30, terlihat HTTP request GET /navi_agent.exe HTTP/1.1 dengan header Host: wired-update.net. Request tersebut dikirim menuju server dengan IP 203.0.113.42. Pada Frame 31, server memberikan response HTTP/1.1 200 OK, yang menunjukkan bahwa request berhasil diproses dan file executable berhasil diakses.

 <img src="assets/17-http.png" width="500">


 | Parameter                | Hasil              |
| ------------------------ | ------------------ |
| Host/Domain          | wired-update.net |
| IP Server Penyerang  | 203.0.113.42     |
| Nama File Executable | navi_agent.exe   |
| HTTP Status Code     | 200 OK           |


## socked server

 <img src="assets/17-socket.png" width="500">

Memvalidasi hasil analisis HTTP C2, seperti domain/Host, IP server, nama executable, dan status HTTP.
## 18. SMB

tujuan menganalisis file capture wired_smb_transfer.pcapng untuk mengidentifikasi nama protokol jaringan yang dieksploitasi, IP pengirim dan penerima, folder tujuan penyimpanan malware pada sistem korban, serta nama file executable malware yang ditransfer.

 <img src="assets/18-smb.png" width="500">

| Parameter     | Hasil                      |
| ------------- | -------------------------- |
| Protokol      | SMB2                     |
| IP Pengirim   | 10.7.3.100               |
| IP Penerima   | 10.7.1.50                |
| Folder Tujuan | System32                 |
| File Malware  | wired_trojan_payload.exe |

## socked server
 <img src="assets/18-socket.png" width="500">

Memvalidasi hasil analisis SMB transfer, seperti protokol, IP pengirim/penerima, folder tujuan, dan nama file.

 ## 19 SMTP
 Menganalisis dengan cara meneror jaringan dan mengirimkan email pemerasan melalui protokol SMTP tanpa enkripsi. Analisis file capture wired_smtp_threat.pcap pada stream TCP terkait, identifikasi alamat email korban yang ditargetkan, password korban yang diklaim bocor oleh penyerang, jenis malware yang diinfeksikan, batas waktu (dalam hari) yang diberikan, serta MailClientID yang tercantum pada pesan. 
```text
220 mail.protocol7.co.jp ESMTP Postfix

EHLO darkwired.net

250-mail.protocol7.co.jp Hello

MAIL FROM:<attacker@darkwired.net>

250 2.1.0 Ok

RCPT TO:<victim@protocol7.co.jp>

250 2.1.5 Ok

DATA

354 End data with <CR><LF>.<CR><LF>

From: attacker@darkwired.net
To: victim@protocol7.co.jp
Subject: URGENT: Your Wired account has been compromised
Date: Thu, 10 Sep 2026 09:00:00 +0700
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8

I have compromised your system through Protocol 7.

I know that: pr0tocol_7_user - is your password!

Your computer was infected with my private ransomware.
I have access to all your files, emails, and The Wired accounts.
I recorded everything through your NAVI terminal.

If you do not pay me 2 BTC to the following address:
bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh

I give you 72 hours (3 days) to get the bitcoins and pay.
After that, I will release everything to The Wired.

Do not try to contact the Knights. They cannot help you.
Let's all love Lain.

MailClientID: 7719980706
.


250 2.0.0 Ok: queued

QUIT

221 2.0.0 Bye
```

 hasil
 | Parameter       | Hasil      |
| --------------- | ---------- |
| Email korban    | victim@protocol7.co.jp |
| Password korban | pr0tocol_7_user        |
| Jenis malware   | ransomwar              |
| Batas waktu     | 3 hari                 |
| MailClientID    | 7719980706             |

## socked server
 <img src="assets/19-socket.png" width="500">

Memvalidasi hasil analisis SMTP threat, seperti email korban, password yang diklaim bocor, jenis malware, deadline, dan MailClientID.

## 20 TLS
menyembunyikan komunikasi malware di balik saluran terenkripsi TLS. Namun Alice telah menyediakan file keylog untuk mendekripsi lalu lintas data tersebut. Analisis file capture wired_tls_decrypt.pcapng bersama keyslogfile.txt untuk mengidentifikasi versi protokol TLS yang dinegosiasikan, nama domain (SNI) yang diakses, alamat IP server HTTPS penyerang, User-Agent yang digunakan, serta HTTP request method dan path yang tersembunyi di dalam sesi dekripsi. Validasi temuan kalian pada socket server

```text
HEAD / HTTP/1.1
Host: example.com
User-Agent: curl/7.62.0
Accept: */*
```
 <img src="assets/20-tls.png" width="500">




| Parameter       | Hasil |
| --------------- | ----- |
| TLS Version     | tlsv1.2       |
| SNI / Domain    | example.com   |
| IP Server HTTPS | 93.184.216.34 |
| User-Agent      | curl/7.62.0 |
| HTTP Method     | HEAD |
| HTTP Path       | /|

## socked server
 <img src="assets/20-socket.png" width="500">
Memvalidasi hasil analisis TLS decryption, seperti TLS version, SNI/domain, IP server, User-Agent, method, dan path HTTP.