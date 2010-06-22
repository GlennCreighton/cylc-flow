#!/usr/bin/env python

#         __________________________
#         |____C_O_P_Y_R_I_G_H_T___|
#         |                        |
#         |  (c) NIWA, 2008-2010   |
#         | Contact: Hilary Oliver |
#         |  h.oliver\@niwa.co.nz   |
#         |    +64-4-386 0461      |
#         |________________________|

import os, sys
from ConfigParser import SafeConfigParser

# system-wide cylc settings

class rc:

    def __init__( self, rcfile=None ):

        if not rcfile:
            rcfile = os.path.join( os.environ['HOME'], '.cylcrc' )

        self.rcfile = rcfile
        self.config = {}
        self.configparser = SafeConfigParser()

        self.config_dir = os.path.join( os.environ[ 'HOME' ], '.cylc' )
        self.lockserver_dir = os.path.join( self.config_dir, 'lockserver' )


        self.config[ 'cylc' ] = {}
        self.config[ 'cylc' ][ 'state dump directory' ] = os.path.join( self.config_dir, 'state-dumps' )
        self.config[ 'cylc' ][ 'logging directory' ] = os.path.join( self.config_dir, 'log-files' )

        self.config[ 'cylc' ][ 'use lockserver' ] = 'False'

        self.config[ 'lockserver' ] = {}
        self.config[ 'lockserver' ][ 'log file' ] = os.path.join( self.lockserver_dir, 'logfile' )
        self.config[ 'lockserver' ][ 'pid file' ] = os.path.join( self.lockserver_dir, 'server.pid' )

        if os.path.exists( rcfile ):
            print "Loading Cylc RC File " + self.rcfile
            self.load()
        else:
            print "Creating new Cylc RC File " + self.rcfile 
            self.write()

        self.create_dirs()

    def load( self ):
        self.configparser.read( self.rcfile )
        for section in self.configparser.sections():
            #print "Loading Section", section
            for (item, value) in self.configparser.items( section ):
                try:
                    self.config[section][ item ] = value
                except:
                    #print '  Using default ', item, self.config[section][ item ]
                    pass
                else:
                    #print '  Loaded item', item, value
                    pass

    def create_dirs( self ):
        for dir in [ self.config_dir, 
                self.config['cylc']['logging directory'],
                self.config['cylc']['state dump directory'],
                os.path.dirname( self.config[ 'lockserver' ][ 'log file' ] ),
                os.path.dirname( self.config[ 'lockserver' ][ 'pid file' ] )]:

            if not os.path.exists( dir ):
                print "Creating directory: " + dir
                os.makedirs( dir )

    def write( self ):
        for section in self.config:
            if not self.configparser.has_section( section ):
                self.configparser.add_section( section )
            for item in self.config[ section ]:
                self.configparser.set( section, item, self.config[ section][item] )

        with open( self.rcfile, 'wb' ) as configfile:
            self.configparser.write( configfile )


    def dump( self ):
        for section in self.config:
            print '[' + section + ']'
            for item in self.config[ section ]:
                print ' ', item, '=', self.config[section][item]

    def get( self, section, item ):
        try:
            return self.config[ section ][ item ]
        except:
            pass

    def get_system_statedump_dir( self, system_name, practice_mode=False ):
        if practice_mode:
            system_name += '-practice'
        dir = os.path.join( self.config[ 'cylc' ][ 'state dump directory' ], system_name )
        if not os.path.exists( dir ):
            print "Creating directory", dir
            os.makedirs( dir )
        return dir

    def get_system_logging_dir( self, system_name, practice_mode=False):
        if practice_mode:
            system_name += '-practice'
        dir = os.path.join( self.config[ 'cylc' ][ 'logging directory' ], system_name )
        if not os.path.exists( dir ):
            print "Creating directory", dir
            os.makedirs( dir )
        return dir

    def get_system_statedump_file( self, system_name ):
        dir = self.get_system_statedump_dir( system_name )
        return os.path.join( dir, 'state' )
