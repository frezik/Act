package Act::Template::Parser;

use strict;
use base qw(Template::Parser);
use constant LANG_RE => qr{<([a-z]{2})>(.*?)</\1>}s;

sub new
{
    my ($class, $options) = @_;
    my $self = $class->SUPER::new();
    $self->init($options);
    return $self;
}

sub init
{
    my ($self, $options) = @_;
    $self->{$_} = $options->{$_} for keys %$options;
}

sub parse
{
    my ($self, $text) = @_;

    # isolate multilingual sections
    $self->_tokenize($text);

    # replace multilingual sections with TT directives
    $text = '';
    for my $section (@{$self->{sections}}) {
        my $translated = $section->{text};
        if ($section->{lang}) {
            $translated =~ s/@{[LANG_RE]}/\[% CASE '$1' %\]$2/gs;
            $text .= '[% SWITCH global.request.language %]'.$translated.'[% END %]';
        }
        else {
            $text .= $translated;
        }
    }
    return $self->SUPER::parse ($text);
}

sub _tokenize
{
    my ($self, $text) = @_;
    return unless defined $text && length $text;

    # extract all sections from the text
    $self->{sections} = [];
    while ($text =~ s!
           ^(.*?)             # $1 - start of line up to start tag
            (?:
                <t>           # start of tag
                (.*?)         # $2 - tag contents
                </t>          # end of tag
            )
            !!sx
          )
    {
        push @{$self->{sections}}, { text => $1 } if $1;
        push @{$self->{sections}}, { lang => 1, text => $2 }
            if defined $2;
    }
    push @{$self->{sections}}, { text => $text } if $text;
}

1;

__END__