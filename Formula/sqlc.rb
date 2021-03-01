class Sqlc < Formula
  desc "Generate type safe Go from SQL"
  homepage "https://sqlc.dev/"
  url "https://github.com/kyleconroy/sqlc/archive/v1.7.0.tar.gz"
  sha256 "bdd425c6087d8115b622a1e0f9251a2d7c645ac2b1a3519621e4a39983a57387"
  license "MIT"
  head "https://github.com/kyleconroy/sqlc.git"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "e87faf917d9893d189b07ba837fcd5b1ba692ffae7dec0cd6aff58ab6b340167"
    sha256 cellar: :any_skip_relocation, big_sur:       "7ba27e3130ae197f3c7d01eb621c0a348192a6c4e612412e4bd947486f5039c0"
    sha256 cellar: :any_skip_relocation, catalina:      "023ffd136b1d9e14e21b232f21a78d962f96b94aa84a8a0eb8fc78f94d121d19"
    sha256 cellar: :any_skip_relocation, mojave:        "c8bb56f206950c30257c404b0619f47486e768a199160652aa716553111e7c28"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args, "-ldflags", "-s -w", "./cmd/sqlc"
  end

  test do
    (testpath/"sqlc.json").write <<~SQLC
      {
        "version": "1",
        "packages": [
          {
            "name": "db",
            "path": ".",
            "queries": "query.sql",
            "schema": "query.sql",
            "engine": "postgresql"
          }
        ]
      }
    SQLC

    (testpath/"query.sql").write <<~EOS
      CREATE TABLE foo (bar text);

      -- name: SelectFoo :many
      SELECT * FROM foo;
    EOS

    system bin/"sqlc", "generate"
    assert_predicate testpath/"db.go", :exist?
    assert_predicate testpath/"models.go", :exist?
    assert_match "// Code generated by sqlc. DO NOT EDIT.", File.read(testpath/"query.sql.go")
  end
end
