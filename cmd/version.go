package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

// Populated at build time via -ldflags, e.g.
//
//	go build -ldflags "-X github.com/alexhokl/cbt/cmd.version=1.2.3 \
//	  -X github.com/alexhokl/cbt/cmd.commit=$(git rev-parse --short HEAD)"
var (
	version = "dev"
	commit  = "none"
)

// versionCmd represents the version command
var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print the version of this application",
	Run: func(cmd *cobra.Command, _ []string) {
		_, _ = fmt.Fprintf(cmd.OutOrStdout(), "%s %s (%s)\n", AppName, version, commit)
	},
}

func init() {
	rootCmd.AddCommand(versionCmd)
}
