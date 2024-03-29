use v6;

use Test;

use-ok('Email::Sender');
use-ok('Email::Sender::Simple');
use-ok('Email::Sender::Transport::Failable');
use-ok('Email::Sender::Transport::Maildir');
use-ok('Email::Sender::Transport::Mbox');
use-ok('Email::Sender::Transport::Null');
use-ok('Email::Sender::Transport::Print');
use-ok('Email::Sender::Transport::SMTP');
use-ok('Email::Sender::Transport::Sendmail');
use-ok('Email::Sender::Transport::Test');
use-ok('Email::Sender::Transport::Wrapper');

done-testing;
