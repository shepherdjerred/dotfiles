ZSH_AUTOSUGGEST_USE_ASYNC=true

ZSH_AUTOSUGGEST_STRATEGY=(histdb history completion)



_zsh_autosuggest_strategy_histdb() {

	typeset -g suggestion

	suggestion=$(_histdb_query "

			SELECT commands.argv

			FROM history

				LEFT JOIN commands ON history.command_id = commands.rowid

				LEFT JOIN places ON history.place_id = places.rowid

			WHERE

				commands.argv LIKE '$(sql_escape $1)%' AND

				places.dir = '$(sql_escape $PWD)'

			GROUP BY commands.argv

			ORDER BY history.start_time desc

			LIMIT 1

	")

}
