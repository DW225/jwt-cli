# JWT CLI
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FDW225%2Fjwt-cli.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2FDW225%2Fjwt-cli?ref=badge_shield)


Simple cli tool for decode jwt token built using zig.

## Dev

### Prerequest

* Install Zig

### Build

```bash
zig build
```

## Usage

```bash
jwt-cli -h --help // Display help info
jwt-cli -t --token <JWT_TOKEN> // Decode JWT token and display Header and Payload
jwt-cli -f --file <TOKEN_FILE_PATH> // Decode JWT token file and display Header and Payload
```


## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FDW225%2Fjwt-cli.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2FDW225%2Fjwt-cli?ref=badge_large)