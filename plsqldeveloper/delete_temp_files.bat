pushd ..
for /r %%a in (*.~*) do del %%a
popd