#!/bin/bash
file=$1  											#define filename variable
if [[ $# -ne 1 ]] ; then
	echo -e "\nUsage: $0 <matches-game>\n" 			#make sure programm gets an argument
	exit
fi
teams=`cut -f1 "$file" | sort | uniq`				#remove all multiple occurances of team in first column, get list of teams

for team in $teams ; do								#use list of teams in 'for each' loop to collect statistics 
	GF=0 GA=0 numwins=0 numlosses=0 numties=0		#initialize count variables as zeroes
	numgames=`grep $team $file | wc -l`				#number of lines where each team appears is a number of games team participated in
	while read line ; do							#read file line by line
			hteam=`echo $line | cut -f1 -d" "`		#split each line by fields and store each field in variable
			gteam=`echo $line | cut -f2 -d" "`
			hgoals=`echo $line | cut -f3 -d" "`
			ggoals=`echo $line | cut -f4 -d" "`
			if [[ "$team" == "$hteam" ]]; then		#case when team plays at home
				GF=$((GF+hgoals))				
				GA=$((GA+ggoals))
				if [[ $hgoals -gt $ggoals ]]; then	#comparing third and forth fields to determine the winner team
					numwins=$((numwins+1))			#and update the counter var
				fi
			elif [[ "$team" == "$gteam" ]]; then	#same as above but in case when team from list plays outside
				GF=$((GF+ggoals))
				GA=$((GA+hgoals))
				if [[ $ggoals -gt $hgoals ]]; then
					numwins=$((numwins+1))
				fi
			fi
			
			if [[ ($hgoals -eq $ggoals) && ($team == $hteam || $team == $gteam) ]]; then #counting ties by checking
					numties=$((numties+1))												 #equality of third and forth fields
			fi
	done < "$file"																		 #while loop gets its input from matches file
	points=$((numwins * 3 + numties))													 #calculating points
	numlosses=$((numgames-numwins-numties))					#number of losses is a compliment to all
															#games played with already calculated numbers of possible match results
	#each time adding new line to line, generated in previous iteration, along with goals for/against difference for further sort														
	table="$table\n$team\t$numgames\t$numwins\t$numties\t$numlosses\t$GF\t$GA\t$points\t$((GF-GA))"
done
#now sort table by desired columns(sort by points then wins act.) getting rid of goals for/against fiels 
sorted=`echo -e $table | sort -rn -k8 -k3 -k9 -k6 | cut -f1-8`
echo -e "Team\tGames\tWins\tTies\tLosses\tGF\tGA\tPoints\n$sorted" | column -t #print the result 