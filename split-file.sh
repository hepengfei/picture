
cat /tmp/picfile.sql|gawk '/^INSERT IGNORE/{n++; if(n%8==0){i++}; f=sprintf("/tmp/picfile.%d.sql",i); print $0 >> f; fflush(f);}'

