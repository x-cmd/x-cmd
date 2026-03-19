$env:PATH += ";C:\Windows\System32"
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
irm get.scoop.sh | iex

# ref: https://github.com/ScoopInstaller/Scoop#readme
scoop install aria2 # accelerate using aria2
scoop install scoop-search
