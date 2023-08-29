In some cases you need to look for malicious Office files in a large amount of files. So do I, at some point we need to Hunt. I just did this script to look for them, create reports and, when MACROS were found, extract only the MACRO, leaving the data behind. Enjoy.

## 💻 Requirements

Before you start, make sure that you environment have these reqs:

* OleTools
https://github.com/decalage2/oletools
* Configure target path
* Assess the file types (there are a lot of files that can contain MACROS)
* Check the log paths and names, and logs if you dare.

## 🚀 Running

You need to configure the path in which you need to hunt for threats:
```
chmod +x maldochunter.sh
```
```
./maldochunter.sh
```
> Warting: it will need a lot of IOPS

## 📫 Contributing for MalDocHunter

If you like to contribute:

1. If you have any ideas, just open an issue and tell me what you think.
2. If you'd like to contribute, please fork the repository and make changes as you'd like. Pull requests are warmly welcome.
3. If your vision of a perfect README.md differs greatly from mine, it might be because your projects are vastly different. In this case, you can create a new file README-yourplatform.md and create the perfect boilerplate for that.
