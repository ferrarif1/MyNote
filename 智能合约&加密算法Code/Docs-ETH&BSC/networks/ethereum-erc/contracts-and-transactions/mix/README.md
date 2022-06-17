# Mix

The IDE Mix is intended to help you as a developer to create, debug and deploy contracts and dapps \(both contracts backend and frontend\).

**WARNING - There are numerous reports of crash-at-boot issues for Mix on OS X. The issue is a** [Heisenbug](https://en.wikipedia.org/wiki/Heisenbug) **which we have been chasing for a month or two. The best workaround we have for right now is to use the Debug configuration, like so:**

```text
cmake -DCMAKE_BUILD_TYPE=Debug ..
```

**WARNING - A replacement for Mix called** [Remix](https://blog.ethereum.org/2016/05/04/c-dev-update-announcing-remix/) **is being worked on, so if you are experiencing issues with Mix, you might be better to look for alternatives until Remix is more mature.**

Start by creating a new project that consists of

* contracts
* html files
* JavaScript files
* style files
* image files

