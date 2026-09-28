package cmd

import (
	"fmt"
	"os"

	"github.com/alexhokl/helper/cli"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

// AppName is the name of this application, used for the config directory name
// and the environment variable prefix. Configuration is read from
// <user config dir>/cbt/config.yaml, which resolves to
// ~/Library/Application Support/cbt on macOS and ~/.config/cbt on Linux.
const AppName = "cbt"

// annotationRequiresService marks a command as requiring a connection to a
// running server. Only commands carrying this annotation are subject to the
// "service" flag validation in PersistentPreRunE; server-side commands such as
// serve are therefore not forced to supply a client-only flag.
const annotationRequiresService = "requiresService"

type rootOptions struct {
	cfgFile                 string
	serviceURI              string
	allowInsecureConnection bool
	verbose                 bool
}

var rootOpts rootOptions

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   AppName,
	Short: "A journal for cognitive behavioural therapy thought records",
	Long: `cbt keeps thought records and maps of worry.

It is a journal, not a therapist: it records what you write and shows it back
to you, and never interprets an entry or offers advice.`,
	SilenceUsage: true,
	PersistentPreRunE: func(cmd *cobra.Command, _ []string) error {
		bindEnvironmentVariablesToRootOptions(&rootOpts)
		if requiresService(cmd) && rootOpts.serviceURI == "" {
			return fmt.Errorf("required flag \"service\" not set (use --service flag, CBT_SERVICE env var, or set \"service\" in config file)")
		}
		return nil
	},
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	// Cobra has already reported the error, so only the exit status is left to
	// set. Without this the shell cannot tell a failed command from a
	// successful one.
	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}

func init() {
	cobra.OnInitialize(initConfig)

	persistentFlags := rootCmd.PersistentFlags()
	persistentFlags.StringVar(&rootOpts.cfgFile, "config", "", fmt.Sprintf("config file (default is <user config dir>/%s/config.yaml)", AppName))
	persistentFlags.StringVarP(&rootOpts.serviceURI, "service", "s", "", "URI of the service to connect to")
	persistentFlags.BoolVarP(&rootOpts.allowInsecureConnection, "insecure", "i", false, "Allow insecure connection to the service")
	persistentFlags.BoolVarP(&rootOpts.verbose, "verbose", "v", false, "Enable verbose output")

	_ = viper.BindPFlag("config", persistentFlags.Lookup("config"))
	_ = viper.BindPFlag("service", persistentFlags.Lookup("service"))
	_ = viper.BindPFlag("insecure", persistentFlags.Lookup("insecure"))
	_ = viper.BindPFlag("verbose", persistentFlags.Lookup("verbose"))
}

func initConfig() {
	cli.ConfigureViper(rootOpts.cfgFile, AppName, rootOpts.verbose, "")
}

// requiresService reports whether the given command needs a service URI to be
// configured before it can run.
func requiresService(cmd *cobra.Command) bool {
	if cmd == nil {
		return false
	}
	return cmd.Annotations[annotationRequiresService] == "true"
}

// bindEnvironmentVariablesToRootOptions fills in any root option that was not
// supplied on the command line from viper (config file or environment).
func bindEnvironmentVariablesToRootOptions(opts *rootOptions) {
	if opts.cfgFile == "" {
		opts.cfgFile = viper.GetString("config")
	}
	if opts.serviceURI == "" {
		opts.serviceURI = viper.GetString("service")
	}
	if !opts.allowInsecureConnection {
		opts.allowInsecureConnection = viper.GetBool("insecure")
	}
	if !opts.verbose {
		opts.verbose = viper.GetBool("verbose")
	}
}
