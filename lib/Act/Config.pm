use strict;
package Act::Config;

use vars qw(@ISA @EXPORT $Config %Request);
@ISA    = qw(Exporter);
@EXPORT = qw($Config %Request);

use AppConfig qw(:expand :argcount);

# our configs
my ($GlobalConfig, %ConfConfigs);

# load configurations
load_configs();

sub load_configs
{
    my $home = $ENV{ACTHOME} or die "ACTHOME environment variable isn't set\n";
    $GlobalConfig = _init_config($home);

    # load global configuration
    _load_config($GlobalConfig, $home);
    _make_hash  ($GlobalConfig, conferences => $GlobalConfig->general_conferences);

    # load conference-specific configuration files
    # their content may override global config settings
    for my $conf (keys %{$GlobalConfig->conferences}) {
        $ConfConfigs{$conf} = _init_config($home);
        _load_config($ConfConfigs{$conf}, $home);
        _load_config($ConfConfigs{$conf}, "$home/$conf");
        # general_conferences isn't overridable
        $ConfConfigs{$conf}->set(conferences => $GlobalConfig->conferences);
    }
    # default current config (for non-web stuff that doesn't call get_config)
    $Config = $GlobalConfig;
}
# get configuration for current request
sub get_config
{
    my $conf = shift;
    return $conf && $ConfConfigs{$conf}
         ? $ConfConfigs{$conf}
         : $GlobalConfig;
}

sub _init_config
{
    my $home = shift;
    my $cfg = AppConfig->new(
         {
            CREATE => 1,
            GLOBAL => {
                   DEFAULT  => "<undef>",
                   ARGCOUNT => ARGCOUNT_ONE,
                   EXPAND   => EXPAND_VAR,
               }
         }
    );
    $cfg->set(home => $home);
    return $cfg;
}

sub _load_config
{
    my ($cfg, $dir) = @_;
    for my $file qw(act local) {
        my $path = "$dir/conf/$file.ini";
        $cfg->file($path) if -e $path;
    }
    # read language settings
    my %languages;
    for my $lang (split /\s+/, $cfg->general_languages) {
        my $section = join '_', 'language', $lang;
        my (%language, $err);
        for my $key (qw(name date_format)) {
            my $s = join '_', $section, $key;
            my $value = $cfg->$s;
            if ($value) {
                $language{$key} = $value;
            }
            else {
                $err = 1;
                last;
            }
        }
        $languages{$lang} = \%language unless $err;
    }
    $cfg->set(languages => \%languages);
}

sub _make_hash
{
    my ($cfg, %h) = @_;
    while (my ($key, $value) = each %h) {
        $cfg->set($key => { map { $_ => 1 } split /\s+/, $value });
    }
}
1;