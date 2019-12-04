#!/usr/bin/perl 
# Cisco (type 7) password tool from www.m00nie.com :D 
# Will either decrypt a _TYPE 7_ password from a cisco device
# or will encrypt a string so that it can be used in a cisco
# device. 
# 
# I made this code to learn more Perl and just out of interest 
# about the type 7 "encryption". The decryption code is already 
# and from a mailing list. The original header from that is below.
#
# Credits for orginal code and description hobbit@avian.org,
# SPHiXe, .mudge et al. and for John Bashinski <jbash@CISCO.COM>
# for Cisco IOS password encryption facts.
#
# Use for any malice or illegal purposes strictly prohibited!
#

@xlat = ( 0x64, 0x73, 0x66, 0x64, 0x3b, 0x6b, 0x66, 0x6f, 0x41,
          0x2c, 0x2e, 0x69, 0x79, 0x65, 0x77, 0x72, 0x6b, 0x6c,
          0x64, 0x4a, 0x4b, 0x44, 0x48, 0x53 , 0x55, 0x42 );

$loop = 0;
while ($loop == 0) {
	print "\n\n***************************************************************\n";
	print "*    Cisco (type 7) password tool from www.m00nie.com :D      *\n";
	print "* Use for any malice or illegal purposes strictly prohibited! *\n";
        print "***************************************************************\n\n";
	print "1. Decrypt a password\n";
	print "2. Encrypt plain text\n";
	print "3. Quit\n\n";
	print "Pick either 1, 2 or 3: ";
	chomp ($choice = <STDIN>);
	if ( $choice == 1 ) {
		decrypt()
	} elsif ( $choice == 2) {
		encrypt()
	} elsif ($choice == 3) {
		exit
	} else {
		print "$choice is not a valid option\n";
	}		
}

sub decrypt {
print "Enter the encrypted password: ";
chomp ($epass = <STDIN>);

        	if (!(length($epass) & 1)) {
                	$ep = $epass; 
			$dpass = "";
                	($s, $e) = ($ep =~ /^(..)(.+)/);
                	for ($i = 0; $i < length($e); $i+=2){
                  		$dpass .= sprintf "%c",hex(substr($e,$i,2))^$xlat[$s++];
			}
            	}
		print "\nEncrypted pass was: $epass\n";
		print "Decrypted pass is: $dpass\n";
}

sub encrypt {
	print "Enter the string to encrypt:\n";
	chomp ($ptext = <STDIN>);
	$pt = $ptext;
	$etext = "";
	$n = 2;
	$etext .=  sprintf("%.2o", $n);
	for ($k = 0; $k < length($pt); $k+=1){
		$tmp = ord(substr($pt,$k,1))^$xlat[$n++];
		$etext .= sprintf("%.2X", $tmp);
	} 
	print "\nPlain string was: $ptext\n";
	print "Encrypted string is: $etext\n";
}
# eof
