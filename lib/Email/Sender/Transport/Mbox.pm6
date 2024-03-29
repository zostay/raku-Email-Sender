use v6

use Email::Sender::Transport;

unit class Email::Sender::Transport::Mbox does Email::Sender::Transport;

has IO::Path $.filename = $*CWD.add('mbox');

method send-email(Email::Simple $email, :@to, :$from --> Email::Sender::Success:D) {
    my $fh = self!open-fh($.filename);

    try {
        if $fh.tell > 0 {
            $fh.write("\n".encode('ascii'));
        }

        $fh.write: self!from-line($email, $from);
        $fh.write: self!escape-from-body($email);
        $fh.write("\n".encode('ascii'))
            unless $email.Str.ends-with("\n");

        self!close-fh($fh);

        CATCH {
            when X::IO {
                die "couldn't write to $.filename: $_";
            }
        }
    }

    self.success;
}

method !open-fh(IO::Path $filename --> IO::Handle:D) {
    my $fh = $filename.open(:w, :a, :bin);
    self!getlock($fh, $filename);
    $fh.seek(0, SeekFromEnd);
    $fh;
}

method !close-fh(IO::Handle $fh) {
    $fh.unlock;
    $fh.close;
}

method !escape-from-body($email) {
    my $body = $email.body-str;
    $body ~~ s:g/^ ("From ")/> $0/;
    $email.body-set($body);
    $email.body;
}

my @dow = <Sun Mon Tue Wed Thu Fri Sat>;
my @mon = <Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec>;
method !from-line($email, $from) {
    my $now = DateTime.now;
    my $fromtime = sprintf "%s %s %2d %02d:%02d:%02d %04d",
        @dow[$now.day-of-week % 7],
        @mon[$now.month-1],
        $now.day,
        $now.hour,
        $now.minute,
        $now.second,
        $now.year;

    "From $from  $fromtime\n".encode('ascii');
}

method !getlock($fh, $fn) {
    for ^10 {
        return if $fh.lock(:non-blocking);
        sleep $_;
    }

    die "couldn't lock file $fn";
}
