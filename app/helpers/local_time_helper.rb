require 'tzinfo'

module LocalTimeHelper
  def get_current_local_time(tz)
    tz = TZInfo::Timezone.get(tz)
    now = tz.now
  end
end
