### Library Extracts
One of the great things about Delphi, promoted in the distant past, is its smart linker.
This means I can store my accumulated experience in *Library Files*. Rather than cutting and pasting from a past project. I include the library directory in my project search path and reference functions directly in my code. 

The functions are loosely grouped into files with semi meaningful names. The smart linker then includes only used functions and object in any executable (witness the lack of green dots when debugging).

This general library approach has a downside when sharing the code for final applications in that you need to do the cutting and pasting previously avoided or produce DCUs of the library code. 

This can be an onerous task as libraries often rely on other libraries, In this repository I have decided to simply publish the libraries used. Most of the code here will not be used in the associated demonstrations.   

I improve and expand my library code as required while maintaining backward compatibility. I have unit tests for much of this functionality. I know test cases should be considered before coding or at the very least written and exercised when adding a procedure or function to a library. I do aim to do this but often I decide that a procedure or function I have just written should go in a library for future use and it is only when it seems not to work that I write the test to assist in debugging. So typically tests are often created to resolve a problem or develop multi-platform compatibility. 

Do not assume functions in these libraries are fully tested. I may not even have ever used some of them, merely saved some code I have come across which I think might be useful sometime. 

