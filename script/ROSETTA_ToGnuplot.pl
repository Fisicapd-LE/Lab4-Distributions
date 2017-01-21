#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper; # Package per testare gli hash vari
use File::Basename;
use 5.010;

# Cosa voglio:
# ./script/ROSETTA_ToGnuplot.pl ./variabili/NomeFileRosetta
# Dato un file .rosetta

#Apri il file di dati in sola lettura
open FILEVAR, "<", $ARGV[0] or die "[Errore]: Errore nell'apertura del file di dati";
#open FILETEMPLATE, "<", $ARGV[1] or die "[Errore]: Errore nell'apertura del file di template";

# se ./ciao/Darth.fener allora $name = Dart, $path = ./ciao/, $suffix = vader
my ($namev,$pathv,$suffixv) = fileparse($ARGV[0],qr/\.[^.]*/); #File delle variabili

my @lines = <FILEVAR>; # Array delle righe
my $operaz = qr/^|[\+\*\/\-\^\(\),;=]|$/; # Variabile regex che contiene i vari "delimitatori di variabile" (operazioni, parentesi...)
my $variabile = qr/[a-zA-Z_][a-zA-Z_0-9]*/; # Nome di variabile, alfanumerica, non può iniziare per un numero
my $numeroint = qr/\-?\d+/;		   # Numero come -4
my $numerofloat = qr/\-?\d+\.\d+/;	   # Numero della forma -3.42 o 42.0
my $numero = qr/$numeroint|$numerofloat/;   # Sia -3 che 3.0, per esempio

# Matcha una funzione f(x,y) (MA NON LA DEFINIZIONE, eg "f(x) = ..." solo f(x) ma NON la parte dopo l'uguale), con dei named groups
# (?<args> ... ) = gruppo di cattura chiamato "args", usabile con \g{args} o con $+{args}
# Parentesi tonde incasinate ma sono necessarie per salvare la roba giusta
my $deffunzione = qr/(?<nomefunzione>$variabile)\((?<argomentifunzione>(($variabile)\,?)*)\)/;
# Include anche f(2), non solo f,x
my $deffunzione2 = qr/(?<nomefunzione>$variabile|$numero)\((?<argomentifunzione>(($variabile|$numero)\,?)*)\)/;


#############################################################################################################
# PREPROCESSORE
my $filesenzacommenti;
my @statements;
CICLOCOMMENTI:
foreach my $linea (@lines) {
	# la x indica che permettiamo spazi e commenti
	next CICLOCOMMENTI if ($linea =~ /^$/ or $linea =~ /^\#.*/); #Salta le righe vuote coi commenti che iniziano con #
	# Altrimenti siamo nei casi sotto
	$linea =~ s/\s//g; # Togli gli spazi
	$filesenzacommenti =  $filesenzacommenti.$linea;
}

@statements = split(';',$filesenzacommenti);
#say @statements;
foreach my $linea (@statements) {
	say $linea
}
say '-' x 30;
#############################################################################################################


#############################################################################################################
# TRADUTTORE
CICLOVAR:
foreach my $linea (@statements) {

	if ($linea =~ / ($variabile)  \=  ($numerofloat) /x) {
		#       ^^^^^      ^^^^^^^^^^^^^^^^
		#       $1               $2
		# Memorizza il primo gruppo di cattura come nome di variabile, e associaci il valore del dopo l'uguale
		# gruppo
		print $linea."\n";
	}
	 # a=3 (e non a=3.0)
	elsif	($linea =~ / ($variabile)  \=  ($numeroint) /x) {
		print $linea.".0\n";
	} 
	
	# Funzione, es fun32(x,y) = x^2+a*x
	# (?<args> ... ) = gruppo di cattura chiamato "args", usabile con \g{args} o con $+{args}
	elsif	
	($linea =~ / (?<nomefunzione> [a-z A-Z _ 0-9]+) \( (?<argomentifunzione> [a-z A-Z _ 0-9 ,]+) \)  \=  (?<corpofunzione> [\+ \* \/ \- \^ \( \) , _ a-z A-Z 0-9]+ ) /x) {
		$linea =~ s/\^/**/g; # GNUPLOT_SPECIFIC Sostituisci ^ con **
		
		# GNUPLOT_SPECIFIC Sostituisci i numeri come 2 in 2.0, ignorando quelli dentro i nomi di variabile o con già il punto
		# Funziona cercando ad esempio espressioni come +2( e non per es il 2 in f2
		while ($linea =~ / ($operaz) ([0-9]+) ($operaz) /x ) {
			$linea =~ s/($operaz) ([0-9]+) ($operaz)/$1$2.0$3/x;
		} 
		print $linea."\n";
	}
	else
	{
		die "[Errore]: Riga in formato sconosciuto";
	}
}
#############################################################################################################
