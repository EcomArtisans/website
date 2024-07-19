import Image from 'next/image';
import config from '~/config';
import LogoIcon from '~/assets/logo.svg';

const Logo = () => (
  <div className="relative flex w-6 h-6">
    <Image alt={config.SITE.name} fill={true} src={LogoIcon} />
    <span className="ml-8 self-center whitespace-nowrap text-xl font-bold text-gray-900 dark:text-white md:text-xl">
      {config.SITE.name}
    </span>
  </div>
);

export { Logo };
