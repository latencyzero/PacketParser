# PacketParser

Copyright ©2013 Latency: Zero, LLC. All rights reserved. This is NOT an open-source project.


## Building

You need LLVM 11-ish. I *think* you can get this from brew:

```
$ brew install llvm
```

To test the fancy LLVM-based metamagical parser thingie, run the unit tests. `testTwoPass` will generate a simple parser, and run some captured packets through it. It doesn't try to verify the results or anything. They get sloppily written to Core Data.

The magic happens in `DecoderRuntime`. Binary parsing begins in `-[parseData:completion:]`, and the runtime writes into the `ManagedObjectContext` with which it was initialized.
