# hash-nric
Hash NRICs in files with MD5

First, make the  script executable:
```
chmod +x hash_nric.sh
```

To hash a file `sample.txt` containing NRICs, execute the following:
```
./hash_nric.sh sample.txt
```
This will produce a file `hashed_sample.txt` in the same directory as `sample.txt` but NRICs are replaced with their MD5 hashes. The prefixed "hashed_" is fixed.

If you want a different name for the output file, then:
```
./hash_nric.sh sample.txt newname.txt
```
This will produce a file `newname.txt` in the same directory as `sample.txt`.