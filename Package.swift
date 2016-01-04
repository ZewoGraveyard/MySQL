import PackageDescription

let package = Package(
    name: "MySQL",
    dependencies: [
        .Package(url: "https://github.com/Zewo/SQL.git", majorVersion: 0),
        .Package(url: "https://github.com/Zewo/CMySQL.git", majorVersion: 1)
    ]
)
