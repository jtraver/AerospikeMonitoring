    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
```
    Dependencies

    You must have citrusleaf_stats.py and citrusleaf_load.py in order for the scripts to work. Some plugins ask for a Nagios plugin dir which will look for citrusleaf_stats.py or citrusleaf_load.py.

    Nagios/Icinga command.cfg examples

define command {
    command_name    chk_as_free_pct_disk
    command_line    /nagiosplugindir/chk_as_free-pct-disk.sh -H $HOSTNAME$ -p 3000 -w $ARG1$ -c $ARG2$ -n /nagiosplugindir
}

define command {
    command_name    chk_as_free_pct_mem
    command_line    $USER1$/chk_as_free-pct-mem.sh -H $HOSTNAME$ -p 3000 -w $ARG1$ -c $ARG2$ -n $USER1$
}

# This nagios check grabs the previous alert output and compares it with the current one.
define command {
    command_name    chk_as_migrate_msgs_recv
    command_line    $USER1$/chk_as_migrate-msgs-recv.sh  -H $HOSTNAME$ -p 3000 -n $USER1$ -o "$SERVICEOUTPUT$"
}

define command {
    command_name    chk_as_stopwrites
    command_line    $USER1$/applovin/chk_as_stopwrites.sh  -H $HOSTNAME$ -p 3000
}
```
