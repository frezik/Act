#  display "Static" multilingual pages

package Act::Static;

use strict;

use Act::Config;
use Act::Template::HTML;

sub handler
{
    my $template = Act::Template::HTML->new();
    $Request{r}->send_http_header('text/html; charset=ISO-8859-1');
    $template->process($Request{path_info});
}
1;