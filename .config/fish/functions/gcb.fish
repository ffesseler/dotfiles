function gcb

	switch (echo $argv)
		case '*'
			git checkout -b fix-IOB-$argv
	end	
end
