# Contributing to Shadoker
*First off, thanks for taking the time to contribute!*

You can contribute by:
* adding packages and Docker definitions for your own product/project to this repository
* improving the shadoker Python tool itself 

In both cases you need to create your own branch and create a pull-request in this repository to get your changes committed in the main branch.
The branch name must be in the format `feature/TICKET-1234` where `TICKET-1234` is an existing Jira issue.
```
git clone ssh://git@dev-bitbucket.fircosoft.net:7999/fir/shadoker.git
cd shadoker
git checkout -b feature/TICKET-1234 
```
Then refer to the [Shadoker user guide page](http://confluence.fircosoft.net/display/DEVOPS/Shadoker) for the exact files and folders to create in your branch. You can review your changes:
```
git status
git diff
```
And you can check your new definitions are valid with these commands (see how to [install the shadoker-cli](README.md) tool):
```
shadoker-cli package ls -w
shadoker-cli docker ls -w
```
Then prepare your pull request:
```
git add <my_changed_files>
git commit -m 'TICKET-1234 my product packages'
git push
```
In BitBucket open the page corresponding to [your branch](http://dev-bitbucket.fircosoft.net/projects/FIR/repos/shadoker/branches) and use the **Create pull request** button.