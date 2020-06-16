timestamp::__module__() {
  timestamp::day() {
    date +%Y-%m-%d
  }

  timestamp::minute() {
    echo "$(time::timestamp::day).$(date +%H-%M)"
  }

  timestamp::second() {
    echo "$(time::timestamp::minute).$(date +%S)"
  }
}