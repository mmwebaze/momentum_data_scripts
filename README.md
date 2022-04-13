# location loader

These Julia script files can be used to carryout bulk location specific data creation on the Drupal KMS platform.
They make use of a location.csv file containing location specific data and post its content to /api/v1/locations resource
endpoint.

## Running the scripts

** Get the token from /jwt/token end-point and save it in Secret.jl as a value key (key_token) pair

** from the REPL run include("Main.jl")

