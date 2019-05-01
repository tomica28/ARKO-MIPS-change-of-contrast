.data
buf:	.space	4000
plik:	.space	30
wynik:	.asciiz "wynik.bmp"
linia:	.asciiz "\n"
tekst1:	.asciiz "Podaj kontrast: "
tekst2:	.asciiz "Podaj nazwe pliku: "
tekst3:	.asciiz	"Zmiana kontrastu(1) Rozciaganie histogramu(2): "
.text
main:
	#wyswietlenie zapytania o plik
	li	$v0, 4
	la	$a0, tekst2
	syscall
	#wczytanie nazwy pliku
	li	$v0, 8
	la	$a0, plik
	li	$a1, 30
	syscall
	#przetworzenie nazwy
	la	$t0, plik
petla:	lbu	$t1, ($t0)
	addiu	$t0, $t0, 1
	bgtz	$t1, petla
	
	sb	$zero, -2($t0)
	#Wyswietlenei zapytania o opcje
	li	$v0, 4
	la	$a0, tekst3
	syscall
	#wczytanie opcji
	li	$v0, 5
	syscall
	move 	$s5, $v0

	#otwarcie pliku obraz
	li	$v0, 13
	la	$a0, plik
	li	$a1, 0
	syscall
	#zapis scizki do obraz do s0
	move	$s0, $v0
	#otwieram plik wynikowy
	li	$v0, 13
	la	$a0, wynik
	li	$a1, 1
	syscall
	#zapis sciezki do obrazu wynikowego w s7
	move	$s7, $v0

	#czytanie z pliku
	li	$v0, 14
	move	$a0, $s0
	la	$a1, buf
	la	$a2, 14
	syscall
	#wskaznik na buf w t0
	la	$t0, buf
	#czytam offset
	addiu	$t0, $t0, 10
	lwr	$t1, ($t0)
	#li	$v0, 1
	#move	$a0, $t1
	#syscall
	#zapisuje offset w s1
	subiu	$s1, $t1, 14

	#zapisuje do pliku wynikowego
	li	$v0, 15
	move	$a0, $s7
	la	$a1, buf
	li	$a2, 14
	syscall
	#wczytuje kolejne znaki
	li	$v0, 14
	move	$a0, $s0
	la	$a1, buf
	la	$a2, 4000
	syscall
	la	$t0, buf
	#wczytauje wielkosc mapy
	addiu	$t0, $t0, 20
	lwr	$t1, ($t0)
	#li	$v0, 1
	#move	$a0, $t1
	#syscall
	#zapisuje wielkosc mapy w s2
	subiu 	$s2, $t1, 4014

	#obliczenie liczby powtorzen petli wczytywania
	div	$s2, $s2, 4000
	addiu	$s2, $s2, 1
	#li	$v0, 1
	#move	$a0, $s2
	#syscall
	#skok jesli histogram
	beq	$s5, 2, histogram
	####przeksztalcenie pierwzego bufora
	la	$t0, buf
	addu	$t0, $t0, $s1
	#wyswietlenie zapytania o kontrast
	li	$v0, 4
	la	$a0, tekst1
	syscall
	#wczytanie kontrastu do s6
	li	$v0, 5
	syscall
	move	$s6, $v0
	#obliczenie wspolczynika i zapisanie w s6
	move	$t7, $s6
	add	$s6, $s6, 255
	mul	$s6, $s6, 259
	li	$t6, 259
	sub	$t7, $t6, $t7
	mul	$t7, $t7, 255
	sll	$s6, $s6, 12
	sll	$t7, $t7, 6
	div	$s6, $s6, $t7
	#obliczenie licznika petli
	li	$t1, 4000
	subu	$t1, $t1, $s1
petla_1:
	lbu	$t7, ($t0)
	sub	$t7, $t7, 128
	sll	$t7, $t7, 6
	mul	$t7, $t7, $s6
	sra	$t7, $t7, 12
	add	$t7, $t7, 128
	#sprawdzenie
	blt	$t7, 255, spr
	la	$t7, 255
spr:	bgtz	$t7, zapisz
	la	$t7, 0
	
zapisz:
	sb	$t7, ($t0)
	addiu	$t0, $t0, 1
	subiu	$t1, $t1, 1
	bgtz	$t1, petla_1
	

	#zapis	do pliku wynikowego
	li	$v0, 15
	move	$a0, $s7
	la	$a1, buf
	li	$a2, 4000
	syscall
	##petla wczytywania i przeksztalcenia
petla_2:
	li	$v0, 14
	move	$a0, $s0
	la	$a1, buf
	li	$a2, 4000
	syscall
	li	$t2, 4000
	la	$t0, buf
petla_wew:
	lbu	$t7, ($t0)
	sub	$t7, $t7, 128
	sll	$t7, $t7, 6
	mul	$t7, $t7, $s6
	sra	$t7, $t7, 12
	add	$t7, $t7, 128
	#sprawdzenie
	blt	$t7, 255, spr1
	la	$t7, 255
spr1:	bgtz	$t7, zapisz1
	la	$t7, 0

	
zapisz1:
	sb	$t7, ($t0)
	
	addiu	$t0, $t0, 1
	subiu	$t2, $t2, 1
	bgtz	$t2, petla_wew
	
	li	$v0, 15
	move	$a0, $s7
	la	$a1, buf
	li	$a2, 4000
	syscall
	subiu	$s2, $s2, 1
	bgtz	$s2, petla_2
	#zamkniecie plikow
	li	$v0, 16
	move	$a0, $s0
	syscall
	move	$a0, $s7
	syscall
	#koniec programu
	li	$v0, 10
	syscall
	
histogram:
	#przeszukanie pierwszego bufora
	la	$t0, buf
	addu	$t0, $t0, $s1

	#obliczenie licznika petli
	li	$t1, 3999
	subu	$t1, $t1, $s1
	lbu	$t7, ($t0)
	move	$s4, $t7
	move	$s5, $t7
	addiu	$t0, $t0, 1


	#sprawdzenie pierwszego bufora
petla_h1:
	lbu	$t7, ($t0)
	beqz	$t7, dalej
	bgt	$t7, $s5, spr_h	
	move	$s5, $t7
spr_h:	blt	$t7, $s4, dalej
	move	$s4, $t7
dalej:	addiu	$t0, $t0, 1
	subiu	$t1, $t1, 1
	
	bgtz	$t1, petla_h1
	move	$t4, $s2


	#sprawdzenie reszty
petla_h2:
	li	$v0, 14
	move	$a0, $s0
	la	$a1, buf
	li	$a2, 4000
	syscall
	li	$t2, 4000
	la	$t0, buf
petla_hwew:
	lbu	$t7, ($t0)
		beqz	$t7, dalej1
	bltu	$t7, $s4, spr_h1
	move	$s4, $t7
spr_h1:	bgtu	$t7, $s5, dalej1
	move	$s5, $t7
dalej1:	addiu	$t0, $t0, 1
	subiu	$t2, $t2, 1
	bgtz	$t2, petla_hwew

	subiu	$t4, $t4, 1
	bgtz	$t4, petla_h2

	#obliczenie wspolcznynikow przeksztalcenia
	sub	$s4, $s4, $s5
	li	$t5, 255
	sll	$t5, $t5, 12
	sll	$s4, $s4, 6
	div	$s4, $t5, $s4
	#debug
	li	$v0, 1
	move	$a0, $s4
	syscall
	###przeksztalcenie obrazu
	#ponowne otwarcie
	li	$v0, 16
	move	$a0, $s0
	syscall
	#otwarcie pliku obraz
	li	$v0, 13
	la	$a0, plik
	li	$a1, 0
	syscall
	move	$s0, $v0
	#czytanie z pliku
	li	$v0, 14
	move	$a0, $s0
	la	$a1, buf
	la	$a2, 14
	syscall
	#czytanie z pliku
	li	$v0, 14
	move	$a0, $s0
	la	$a1, buf
	la	$a2, 4000
	syscall

	la	$t0, buf
	addu	$t0, $t0, $s1
	
	#obliczenie licznika petli
	li	$t1, 4000
	subu	$t1, $t1, $s1
	##przeksztalcenie pierwszego bufora
petla_zmien1:
	lbu	$t7, ($t0)
	sub	$t7, $t7, $s5
	sll	$t7, $t7, 6
	mul	$t7, $t7, $s4
	sra	$t7, $t7, 12


	sb	$t7, ($t0)
	addiu	$t0, $t0, 1
	subiu	$t1, $t1, 1
	bgtz	$t1, petla_zmien1
	
	#zapis	do pliku wynikowego
	li	$v0, 15
	move	$a0, $s7
	la	$a1, buf
	li	$a2, 4000
	syscall
	##przeksztalcenie kolejnych buforow
petla_zmien2:
	li	$v0, 14
	move	$a0, $s0
	la	$a1, buf
	li	$a2, 4000
	syscall
	li	$t2, 4000
	la	$t0, buf
petla_zmienwew:
	lbu	$t7, ($t0)
	sub	$t7, $t7, $s5
	sll	$t7, $t7, 6
	mul	$t7, $t7, $s4
	sra	$t7, $t7, 12


	sb	$t7, ($t0)
	addiu	$t0, $t0, 1
	subiu	$t2, $t2, 1
	bgtz	$t2, petla_zmienwew
	
	li	$v0, 15
	move	$a0, $s7
	la	$a1, buf
	li	$a2, 4000
	syscall
	subiu	$s2, $s2, 1
	bgtz	$s2, petla_zmien2
	#zamkniecie plikow
	li	$v0, 16
	move	$a0, $s0
	syscall
	move	$a0, $s7
	syscall
	#koniec progrmu
	li	$v0, 10
	syscall
