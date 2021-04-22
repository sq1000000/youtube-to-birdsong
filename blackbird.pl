use warnings;
use strict;

# Required: csdr, sox

my $infile = "cc.mp3";
my $rate   = 44100;
my $fscale = 24000;

# Shift fundamental to baseband
# And filter harmonics out
system("sox $infile -t .f32 -c 2 - | ".
       "csdr shift_math_cc -0.005 | ".
       "sox -t .f32 -r $rate -c 2 - shifted.wav sinc -140 -n 1024");

# FM demodulation to find fundamental frequency
system("sox shifted.wav -t .f32 - | ".
       "csdr shift_math_cc 0.005 | ".
       "csdr fmdemod_quadri_cf | ".
       "sox -t .f32 -c 1 -r $rate - fmdemod.wav");

# AM demodulation to use as a "squelch"
system("sox shifted.wav -t .f32 - | ".
       "csdr amdemod_cf | ".
       "sox -t .f32 -r $rate -c 1 - amdemod.wav sinc -70 -n 1024");

open my $fm_in, "sox fmdemod.wav -t .f32 - sinc -70 -n 1024|";
open my $amp_in, "sox amdemod.wav -t .f32 -|";
open my $out, "|sox -t .f32 -c 1 -r $rate - birdson3.wav";

my $phase = 0;
my $t = 0;
while (not eof $fm_in) {
  read $fm_in, my $fmdemod, 4;
  $fmdemod = unpack "f", $fmdemod;
  read $amp_in, my $amdemod, 4;
  $amdemod = unpack "f", $amdemod;

  my $freq = $fmdemod * 2 * 3.14159265 / $rate;
  $phase += $freq * $fscale;

  print $out pack "f", sin($phase * 6) * $amdemod;

  $t += 1 / $rate;
}
