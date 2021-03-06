use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = "0.02";
%IRSSI = (
   authors     => 'Donald Ephraim Curtis',
   contact     => 'dcurtis@cs.uiowa.edu',
   name        => 'notify.pl',
   description => 'notify libNotify of irssi message',
   license     => 'GNU General Public License',
);

sub notify {
   my ($title, $text) = @_;
   my $icon = "/usr/share/icons/Tango/32x32/actions/mail-forward.png";
   my %replacements = (
       '<' => '<',
       '>' => '>',
       '&' => '&',
       '"' => '\"',
   );

   # lazy way of constructing the regexp - I've done enough typing already!
   my $replacement_string = join '', keys %replacements;
   my $arguments;

   $title =~ s/([\Q$replacement_string\E])/$replacements{$1}/g;
   $text =~ s/([\Q$replacement_string\E])/$replacements{$1}/g;

   if ($text =~ m/<.(.*)>\s*(.*)/)
   {
   	$arguments = "\"$1 from $title said:\" \"$2\"";
   }
   else
   {
	$arguments = "\"$title says:\" \"$text\"";
   }
   $arguments = $arguments . " -i $icon";
   system("notify-send " . $arguments);

#   my $name = $1;
#   my $message = $2;

   system("echo $arguments >> /home/kasuko/.logs/irssi.log");

}


sub highlight {
   my ($dest, $msg, $stripped) = @_;

   my $window = Irssi::active_win();

   if (($dest->{level} & MSGLEVEL_HILIGHT) && ($dest->{level} &
MSGLEVEL_PUBLIC)) {
       notify($dest->{target}, $stripped);
   }

}

sub query {
   my ($server, $msg, $nick, $addr) = @_;

   my $window = Irssi::active_win();

   my $itemwindow = $server->window_find_item($nick);
   if ($window->{refnum} != $itemwindow->{refnum}) {
       notify($nick, $msg);
   }
}

Irssi::signal_add('print text', 'highlight');
Irssi::signal_add('message private', 'query');
