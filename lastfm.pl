###############################################################################
#
#    lastfm.pl for weechat
#        description:	Now playing script using last.fm for weechat.
#	 usage:		/set plugins.var.python.lastfm.username
#		        <yourusername>
#			/np
#	 author:	Janne Haapsaari <haaja@iki.fi>
#	 licence:	GPL3
#	 version:	0.1
#
###############################################################################

use strict;
use warnings;
use LWP::Simple;
use XML::Simple;

# settings
my %settings = (
    username => "yourusername",
    apikey => "abb245873128d3a6b1a0c8fdc4ac7fc1",
    command => "np",
);

# --------------------------------[ init ]--------------------------------------
weechat::register("lastfm", "haaja <haaja\@iki.fi>", "0.1", "GPL3", 
    "Now playing script using last.fm for weechat.", "", "");

foreach my $option (keys %settings) {
    if (!weechat::config_is_set_plugin($option)) {
        weechat::config_set_plugin($option, $settings{$option});
    }
}

read_config();

weechat::hook_command($settings{command}, "", "", "", "", "lastfm_np", "");
weechat::hook_config("plugins.var.perl.lastfm.*", "read_config", "");
# ------------------------------------------------------------------------------

sub read_config {
    foreach my $option (keys %settings) {
        $settings{$option} = weechat::config_get_plugin($option);
    }

    return weechat::WEECHAT_RC_OK;
}


sub lastfm_np {
    my ($data, $buffer, $args) = @_;
    my $url = "http://ws.audioscrobbler.com/2.0/?method=user."
            ."getrecenttracks&user=$settings{username}&api_key=$settings"
            ."{apikey}&limit=1";

    my $lastfm = get($url);
    my $xml = new XML::Simple;
    my $lastfm_data = $xml->XMLin($lastfm, ForceArray => 1);

    if ($lastfm_data->{status} eq "ok") {
        my $artist = $lastfm_data->{recenttracks}->[0]->{track}->[0]->{artist}->[0]->{content};
        my $song = $lastfm_data->{recenttracks}->[0]->{track}->[0]->{name}->[0];
        my $playing = $lastfm_data->{recenttracks}->[0]->{track}->[0]->{nowplaying};

        if ($playing) {
            weechat::command($buffer, "np: $artist - $song");
        }
        else {
            weechat::print($buffer, "ERROR: You are not playing anything "
                ."according to Last.fm.");
        }
    }

    return weechat::WEECHAT_RC_OK;
}
